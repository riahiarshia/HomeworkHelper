const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const openaiService = require('../backend/services/openaiService');
const WolframService = require('../Services/wolframService');

const router = express.Router();

// Initialize Wolfram|Alpha service
const wolframService = new WolframService();

// Configure multer for file uploads
const upload = multer({
  dest: 'uploads/',
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

// Debug log file path
const DEBUG_LOG_FILE = path.join(__dirname, '../debug-math-responses.log');

// Ensure debug log directory exists
const debugLogDir = path.dirname(DEBUG_LOG_FILE);
if (!fs.existsSync(debugLogDir)) {
  fs.mkdirSync(debugLogDir, { recursive: true });
}

// Helper function to log debug information
function logDebugInfo(logData) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    sessionId: logData.sessionId || 'unknown',
    ...logData
  };
  
  const logLine = JSON.stringify(logEntry, null, 2) + '\n' + '='.repeat(80) + '\n\n';
  
  try {
    fs.appendFileSync(DEBUG_LOG_FILE, logLine);
    console.log(`📝 Debug log written: ${logData.type || 'unknown'}`);
  } catch (error) {
    console.error('❌ Failed to write debug log:', error);
  }
}

// Generate unique session ID
function generateSessionId() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// POST /api/debug-math - Submit image for comprehensive debugging
router.post('/debug-math', upload.single('image'), async (req, res) => {
  const sessionId = generateSessionId();
  
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No image file provided'
      });
    }

    console.log(`🔍 Starting debug session: ${sessionId}`);
    console.log(`📁 Image file: ${req.file.filename}`);

    // Log initial request
    logDebugInfo({
      type: 'REQUEST_START',
      sessionId,
      imageFile: req.file.filename,
      imageSize: req.file.size,
      imageMimetype: req.file.mimetype,
      timestamp: new Date().toISOString()
    });

    // Step 1: Validate image quality
    console.log('📊 Step 1: Validating image quality...');
    const imageValidation = await openaiService.validateImageQuality(req.file.path);
    
    logDebugInfo({
      type: 'IMAGE_VALIDATION',
      sessionId,
      validationResult: imageValidation,
      step: 1
    });

    if (!imageValidation.isValid) {
      return res.json({
        success: false,
        error: 'Image validation failed',
        details: imageValidation,
        sessionId
      });
    }

    // Step 2: Analyze homework with OpenAI and Wolfram|Alpha integration
    console.log('🤖 Step 2: Analyzing homework with OpenAI + Wolfram|Alpha...');
    const homeworkAnalysis = await openaiService.analyzeHomeworkWithWolfram({
      imageData: fs.readFileSync(req.file.path),
      problemText: req.body.problemText || '',
      userGradeLevel: req.body.gradeLevel || 'Middle School',
      apiKey: process.env.OPENAI_API_KEY,
      userId: 'debug-user',
      deviceId: 'debug-device'
    });
    
    logDebugInfo({
      type: 'OPENAI_WOLFRAM_ANALYSIS',
      sessionId,
      analysisResult: homeworkAnalysis,
      wolframUsed: homeworkAnalysis.wolframAlpha?.used || false,
      step: 2
    });

    // Step 3: Test deterministic math evaluation
    console.log('🧮 Step 3: Testing deterministic math evaluation...');
    let mathEvaluation = null;
    let mathErrors = [];

    if (homeworkAnalysis.calc && homeworkAnalysis.calc.expression) {
      try {
        mathEvaluation = deterministicMath.evaluateExpression(homeworkAnalysis.calc.expression);
        
        logDebugInfo({
          type: 'DETERMINISTIC_MATH_EVALUATION',
          sessionId,
          expression: homeworkAnalysis.calc.expression,
          evaluationResult: mathEvaluation,
          step: 3
        });
      } catch (error) {
        mathErrors.push({
          type: 'evaluation_error',
          message: error.message,
          expression: homeworkAnalysis.calc.expression
        });
        
        logDebugInfo({
          type: 'DETERMINISTIC_MATH_ERROR',
          sessionId,
          error: error.message,
          expression: homeworkAnalysis.calc.expression,
          step: 3
        });
      }
    }

    // Step 4: Test Wolfram|Alpha directly for math problems
    console.log('🧮 Step 4: Testing Wolfram|Alpha directly...');
    let wolframTest = null;
    
    if (homeworkAnalysis.wolframAlpha?.used) {
      try {
        // Test Wolfram|Alpha with the detected math problem
        const mathProblem = req.body.problemText || '2 + 2';
        wolframTest = await wolframService.solveMathProblem(mathProblem);
        
        logDebugInfo({
          type: 'WOLFRAM_DIRECT_TEST',
          sessionId,
          problem: mathProblem,
          result: wolframTest,
          step: 4
        });
      } catch (error) {
        logDebugInfo({
          type: 'WOLFRAM_DIRECT_ERROR',
          sessionId,
          error: error.message,
          step: 4
        });
      }
    } else {
      logDebugInfo({
        type: 'WOLFRAM_SKIPPED',
        sessionId,
        reason: 'Not a math problem or Wolfram not used',
        step: 4
      });
    }

    // Step 5: Test answer verification
    console.log('✅ Step 5: Testing answer verification...');
    let answerVerification = null;
    
    if (homeworkAnalysis.answer) {
      try {
        answerVerification = deterministicMath.verifyAnswer(
          homeworkAnalysis.calc?.expression || '',
          homeworkAnalysis.answer
        );
        
        logDebugInfo({
          type: 'ANSWER_VERIFICATION',
          sessionId,
          expression: homeworkAnalysis.calc?.expression || '',
          answer: homeworkAnalysis.answer,
          verificationResult: answerVerification,
          step: 4
        });
      } catch (error) {
        mathErrors.push({
          type: 'verification_error',
          message: error.message,
          answer: homeworkAnalysis.answer
        });
        
        logDebugInfo({
          type: 'ANSWER_VERIFICATION_ERROR',
          sessionId,
          error: error.message,
          answer: homeworkAnalysis.answer,
          step: 4
        });
      }
    }

    // Step 5: Test hint generation
    console.log('💡 Step 5: Testing hint generation...');
    let hintGeneration = null;
    
    try {
      hintGeneration = await openaiService.generateHint(
        homeworkAnalysis.problem || 'Test problem',
        homeworkAnalysis.answer || 'Test answer',
        homeworkAnalysis.calc?.expression || '2+2'
      );
      
      logDebugInfo({
        type: 'HINT_GENERATION',
        sessionId,
        hintResult: hintGeneration,
        step: 5
      });
    } catch (error) {
      mathErrors.push({
        type: 'hint_generation_error',
        message: error.message
      });
      
      logDebugInfo({
        type: 'HINT_GENERATION_ERROR',
        sessionId,
        error: error.message,
        step: 5
      });
    }

    // Step 6: Test answer verification endpoint
    console.log('🔍 Step 6: Testing answer verification endpoint...');
    let answerVerificationEndpoint = null;
    
    try {
      answerVerificationEndpoint = await openaiService.verifyAnswer(
        homeworkAnalysis.problem || 'Test problem',
        homeworkAnalysis.answer || 'Test answer',
        homeworkAnalysis.calc?.expression || '2+2'
      );
      
      logDebugInfo({
        type: 'ANSWER_VERIFICATION_ENDPOINT',
        sessionId,
        verificationEndpointResult: answerVerificationEndpoint,
        step: 6
      });
    } catch (error) {
      mathErrors.push({
        type: 'verification_endpoint_error',
        message: error.message
      });
      
      logDebugInfo({
        type: 'ANSWER_VERIFICATION_ENDPOINT_ERROR',
        sessionId,
        error: error.message,
        step: 6
      });
    }

    // Compile comprehensive debug report
    const debugReport = {
      sessionId,
      timestamp: new Date().toISOString(),
      imageValidation,
      homeworkAnalysis,
      mathEvaluation,
      wolframTest,
      answerVerification,
      hintGeneration,
      answerVerificationEndpoint,
      errors: mathErrors,
      summary: {
        imageValid: imageValidation.isValid,
        analysisComplete: !!homeworkAnalysis,
        wolframUsed: homeworkAnalysis.wolframAlpha?.used || false,
        wolframAnswer: homeworkAnalysis.wolframAlpha?.answer || null,
        mathExpressionFound: !!homeworkAnalysis.calc?.expression,
        mathEvaluationSuccess: !!mathEvaluation,
        wolframDirectTestSuccess: !!wolframTest,
        answerVerificationSuccess: !!answerVerification,
        hintGenerationSuccess: !!hintGeneration,
        totalErrors: mathErrors.length
      }
    };

    // Log final comprehensive report
    logDebugInfo({
      type: 'COMPREHENSIVE_DEBUG_REPORT',
      sessionId,
      report: debugReport
    });

    // Clean up uploaded file
    try {
      fs.unlinkSync(req.file.path);
      console.log(`🗑️ Cleaned up uploaded file: ${req.file.filename}`);
    } catch (cleanupError) {
      console.error('⚠️ Failed to clean up uploaded file:', cleanupError);
    }

    console.log(`✅ Debug session completed: ${sessionId}`);

    res.json({
      success: true,
      sessionId,
      debugReport,
      logFile: DEBUG_LOG_FILE,
      message: 'Debug analysis complete. Check the log file for detailed results.'
    });

  } catch (error) {
    console.error('❌ Debug session failed:', error);
    
    logDebugInfo({
      type: 'SESSION_ERROR',
      sessionId,
      error: error.message,
      stack: error.stack
    });

    // Clean up uploaded file on error
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (cleanupError) {
        console.error('⚠️ Failed to clean up uploaded file after error:', cleanupError);
      }
    }

    res.status(500).json({
      success: false,
      error: 'Debug session failed',
      details: error.message,
      sessionId
    });
  }
});

// GET /api/debug-math/logs - Get recent debug logs
router.get('/debug-math/logs', (req, res) => {
  try {
    if (!fs.existsSync(DEBUG_LOG_FILE)) {
      return res.json({
        success: true,
        logs: [],
        message: 'No debug logs found'
      });
    }

    const logContent = fs.readFileSync(DEBUG_LOG_FILE, 'utf8');
    const logEntries = logContent.split('='.repeat(80)).filter(entry => entry.trim());
    
    // Parse last 10 entries
    const recentLogs = logEntries.slice(-10).map(entry => {
      try {
        return JSON.parse(entry.trim());
      } catch (parseError) {
        return { raw: entry.trim(), parseError: parseError.message };
      }
    });

    res.json({
      success: true,
      logs: recentLogs,
      totalEntries: logEntries.length,
      logFile: DEBUG_LOG_FILE
    });

  } catch (error) {
    console.error('❌ Failed to read debug logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to read debug logs',
      details: error.message
    });
  }
});

// DELETE /api/debug-math/logs - Clear debug logs
router.delete('/debug-math/logs', (req, res) => {
  try {
    if (fs.existsSync(DEBUG_LOG_FILE)) {
      fs.unlinkSync(DEBUG_LOG_FILE);
    }
    
    res.json({
      success: true,
      message: 'Debug logs cleared'
    });

  } catch (error) {
    console.error('❌ Failed to clear debug logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to clear debug logs',
      details: error.message
    });
  }
});

// GET /api/debug-math/test - Test the debug system
router.get('/debug-math/test', async (req, res) => {
  const sessionId = generateSessionId();
  
  try {
    // Test Wolfram|Alpha service
    const wolframTest = await wolframService.testService();
    
    logDebugInfo({
      type: 'SYSTEM_TEST',
      sessionId,
      message: 'Debug system test with Wolfram|Alpha',
      timestamp: new Date().toISOString(),
      wolframTest
    });

    res.json({
      success: true,
      message: 'Debug system is working with Wolfram|Alpha integration',
      sessionId,
      logFile: DEBUG_LOG_FILE,
      wolframAlpha: wolframTest,
      features: [
        'Image upload and validation',
        'OpenAI homework analysis',
        'Wolfram|Alpha math solving',
        'Deterministic math evaluation',
        'Answer verification',
        'Hint generation',
        'Comprehensive logging'
      ]
    });
  } catch (error) {
    logDebugInfo({
      type: 'SYSTEM_TEST_ERROR',
      sessionId,
      error: error.message,
      timestamp: new Date().toISOString()
    });

    res.status(500).json({
      success: false,
      error: 'Test failed',
      details: error.message,
      sessionId
    });
  }
});

module.exports = router;

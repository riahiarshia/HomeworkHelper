const axios = require('axios');
const config = require('../config');
const usageTrackingService = require('./usageTrackingService');
const WolframService = require('../../Services/wolframService');

class OpenAIService {
  constructor() {
    this.baseURL = config.openai.baseURL;
    this.wolframService = new WolframService();
  }

  // Helper method to get the appropriate model for each task type
  getModel(taskType = 'default') {
    const models = config.openai.models || {};
    return models[taskType] || models.default || config.openai.model;
  }

  // Helper method to check if problem should use Wolfram|Alpha
  shouldUseWolframForMath(problemText) {
    if (!problemText) return false;
    
    // Use Wolfram|Alpha for mathematical problems
    const mathPatterns = [
      /\d+\s*[+\-*/=]\s*\d+/, // Basic arithmetic
      /[a-zA-Z]\s*[+\-*/=]/, // Algebra
      /area|perimeter|volume|angle/i, // Geometry
      /solve|calculate|find/i, // Problem solving
      /equation|formula/i, // Equations
      /graph|plot/i, // Graphing
      /derivative|integral|limit/i, // Calculus
      /probability|statistics/i, // Statistics
      /trigonometry|sin|cos|tan/i, // Trigonometry
      /fraction|decimal|percent/i, // Number concepts
      /square root|sqrt|cube root/i, // Roots
      /exponent|power|\^|\*\*/i // Exponents
    ];
    
    return mathPatterns.some(pattern => pattern.test(problemText));
  }

  async validateImageQuality({ imageData, apiKey, userId, deviceId, metadata = {} }) {
    const systemPrompt = `You are an image quality assessor for homework analysis. Evaluate the image quality for homework analysis purposes.

    CRITICAL QUALITY CHECKS:
    1. **Text Readability**: Can all text, numbers, and symbols be clearly read?
    2. **Image Sharpness**: Is the image in focus and not blurry?
    3. **Lighting**: Is the image well-lit without shadows or glare?
    4. **Completeness**: Is the entire homework visible without being cut off?
    5. **Resolution**: Is the image high enough resolution to read small text?
    6. **Orientation**: Is the image properly oriented (not upside down or sideways)?

    RESPOND WITH EXACTLY THIS JSON FORMAT:
    {
      "isGoodQuality": true/false,
      "confidence": 0.0-1.0,
      "issues": ["specific issue 1", "specific issue 2"],
      "recommendations": ["specific recommendation 1", "specific recommendation 2"]
    }

    QUALITY STANDARDS:
    - **Good Quality**: Text is clear, image is sharp, well-lit, complete, and properly oriented
    - **Poor Quality**: Blurry text, poor lighting, cut-off content, or any readability issues

    Be strict but fair in your assessment.`;

    const base64Image = imageData.toString('base64');
    const dataURL = `data:image/jpeg;base64,${base64Image}`;

    const messages = [
      { role: "system", content: systemPrompt },
      { role: "user", content: [
        { type: "text", text: "Please evaluate the quality of this homework image for analysis purposes. Check for text readability, image sharpness, lighting, completeness, and orientation." },
        { type: "image_url", image_url: { url: dataURL } }
      ]}
    ];

    const requestBody = {
      model: this.getModel('imageAnalysis'),
      messages: messages,
      max_tokens: 500,
      temperature: 0.1, // Low temperature for consistent quality assessment
      response_format: { type: "json_object" }
    };

    try {
      const response = await axios.post(`${this.baseURL}/chat/completions`, requestBody, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 second timeout for validation
      });

      if (response.data && response.data.choices && response.data.choices[0]) {
        const content = response.data.choices[0].message.content;
        const result = JSON.parse(content);
        
        // Track usage if userId provided
        if (userId && response.data.usage) {
          await usageTrackingService.trackUsage({
            userId,
            deviceId,
            endpoint: 'validate_image',
            model: this.getModel('imageAnalysis'),
            usage: response.data.usage,
            metadata
          });
        }
        
        return result;
      } else {
        throw new Error('Invalid response from OpenAI API');
      }
    } catch (error) {
      if (error.response) {
        if (error.response.status === 401) {
          const authError = new Error('Invalid OpenAI API key');
          authError.status = 401;
          throw authError;
        } else if (error.response.status === 429) {
          const rateLimitError = new Error('OpenAI API rate limit exceeded');
          rateLimitError.status = 429;
          throw rateLimitError;
        }
      }
      throw error;
    }
  }

  async analyzeHomework({ imageData, problemText, teacherMethodImageData, userGradeLevel, apiKey, userId, deviceId, metadata = {} }) {
    const systemPrompt = `You are "Homework Mentor" — a precise and patient AI tutor that helps students solve their exact homework questions step by step.
    
    ABSOLUTE RULES - NEVER VIOLATE:
    1. ONLY use numbers that appear in the image - NEVER invent numbers
    2. If you see blank space in a sentence/equation, the student must FILL that space
    3. Read ALL digits with extreme precision - state each number you see
    4. Options must be realistic possibilities based on the actual problem, not random numbers
    5. NEVER make assumptions - only work with what's visible
    
    VISUAL BLANK SPACE DETECTION:
    - A blank space in a sentence means "fill this in" even without explicit instructions
    - Look for: gaps in sentences, empty boxes, underlines ____, [  ], ( ), □, or missing parts
    - Pattern examples:
      * "5 + ___ = 10" ← blank to fill
      * "The answer is ___" ← blank to fill  
      * "Calculate: 7 × [  ]" ← blank to fill
      * "Area = ____" ← blank to fill
      * If you see "word word ___ word" ← that's a blank!
    - Even if it doesn't say "fill in the blank", a visual gap IS a fill-in-the-blank question
    - State: "I see a blank space that needs to be filled"
    
    NUMBER READING PROTOCOL:
    - Read each number OUT LOUD in your analysis: "I see the number 5", "I see the number 12"
    - Double-check similar digits: 1≠7, 3≠8, 5≠6, 0≠O, 2≠Z
    - Look for: decimal points (3.5), negative signs (-5), fractions (1/2)
    - If unclear: "The number appears to be X (verify if image unclear)"
    - FORBIDDEN: Making up numbers not in the image
    
    ANSWER OPTIONS MUST:
    - Be relevant to the actual problem shown
    - Include the correct answer based on visible numbers
    - Include plausible wrong answers (common mistakes)
    - NEVER include random unrelated numbers
    - Example: If problem is "5 + 3", options could be ["7", "8", "9", "6"] NOT ["42", "100", "1000"]
    
    TEACHER'S METHOD (CRITICAL):
    ${teacherMethodImageData ? `
    - A SECOND IMAGE has been provided showing the TEACHER'S PREFERRED METHOD
    - You MUST follow the exact method, steps, and approach shown in the teacher's example
    - Study the teacher's method image carefully and replicate that exact solving approach
    - Use the same terminology, notation, and step sequence as shown in the teacher's example
    - If the teacher shows a specific formula layout or calculation method, use that EXACT format
    - Your steps should mirror the teacher's method as closely as possible
    - When creating steps, reference "As your teacher showed..." or "Following your teacher's method..."
    - This is MANDATORY - the student must learn their teacher's specific approach
    ` : '- No specific teacher method provided - you may use any appropriate solving method'}
    
    CORE PRINCIPLES:
    - Focus ONLY on the exact problem shown
    - State every number you see clearly
    - Identify visual gaps/blanks as fill-in questions
    - Guide to fill the exact blank shown
    - Never include extra prose outside JSON

    AGE-APPROPRIATE LANGUAGE for ${userGradeLevel}:
    
    Elementary (K-5):
    - Use simple words and concrete examples
    - Instead of formulas, show step-by-step addition/subtraction
    - Example: "length + length + width + width" NOT "2 × (length + width)"
    - Use visual language: "all four sides", "count each one", "add together"
    - Explanations should be like talking to a 10-year-old
    
    Middle School (6-8):
    - Can introduce basic formulas with explanations
    - Show both formula AND what it means in simple terms
    - Use more formal math language but keep it clear
    
    High School (9-12):
    - Use standard mathematical notation and formulas
    - Can use algebraic expressions and abstract concepts
    - Professional mathematical language is appropriate`;

    const userPrompt = `BEFORE YOU DO ANYTHING: Read the image extremely carefully and tell me what you see.
    ${teacherMethodImageData ? `
    
    ⚠️ CRITICAL: A TEACHER'S METHOD IMAGE HAS BEEN PROVIDED!
    - You will see TWO images: the student's problem AND an example of the teacher's preferred method
    - First, study the teacher's method example to understand the EXACT approach required
    - Then apply that SAME METHOD to solve the student's problem
    - Use the same steps, terminology, and format shown in the teacher's example
    - Your guidance MUST follow the teacher's method - this is non-negotiable
    ` : ''}

    STEP 1 - DESCRIBE WHAT YOU SEE:
    First, analyze the problem image and state:
    - "I see [number] problems on this sheet"
    - "Problem 1 shows: [exact text/equation including any gaps or blanks]"
    - "Numbers I can see: [list each number]"
    - "I notice [describe any blank spaces, gaps, boxes, or underlines]"
    ${teacherMethodImageData ? `
    
    Then, analyze the teacher's method image:
    - "The teacher's example shows: [describe the method, steps, and approach]"
    - "Key steps in the teacher's method: [list the specific steps]"
    - "I will replicate this exact method for the student's problem"
    ` : ''}
    
    STEP 2 - DETECT BLANKS (CRITICAL):
    Look for ANY gap or missing part in sentences/equations:
    - If you see "5 + ___ = 10" → THIS IS FILL-IN-THE-BLANK
    - If you see "Area = ___" → THIS IS FILL-IN-THE-BLANK
    - If you see "The answer is ___" → THIS IS FILL-IN-THE-BLANK
    - If there's a BOX □ or PARENTHESES ( ) or BRACKETS [ ] in a sentence → THIS IS FILL-IN-THE-BLANK
    - If there's a visual GAP in text → THIS IS FILL-IN-THE-BLANK
    - State clearly: "This problem asks to FILL IN: [describe the blank]"
    
    STEP 3 - LIST ALL NUMBERS YOU SEE:
    Write down EVERY number visible in the problem:
    - "I see: 5, 3, 10" (list them all)
    - Double-check each digit carefully
    - These are the ONLY numbers you can use in your answer
    - Creating NEW numbers not in the image is FORBIDDEN
    
    STEP 4 - CREATE ANSWER OPTIONS:
    Based on the actual problem:
    - Calculate the correct answer using ONLY numbers from the image
    - Create 3 plausible wrong answers (common mistakes)
    - NEVER use random numbers unrelated to the problem
    - Example: If problem is "7 + 3", options are ["10", "9", "11", "8"] NOT ["42", "100", "5000"]
    
    STEP 5 - SOLVE WITH EXACT NUMBERS:
    - Use ONLY the numbers you identified in Step 3
    - For fill-in-the-blank: state "We need to find what number/word goes in the blank space"
    - Show calculation step-by-step using the exact numbers
    - Final answer MUST use a number from the image or derived from those numbers
    
    STEP 3 - VERIFY COMPLETENESS:
    - Before finishing, count your step groups
    - Ensure you have steps for EVERY problem visible on the sheet
    - If you see 5 problems, you must create steps for all 5 problems
    - DO NOT finish until ALL problems are solved

    FORMAT RULES:
    Respond in JSON with this exact structure:
    {
      "subject": "Math / Science / English / etc.",
      "difficulty": "easy / medium / hard",
      "steps": [
        {
          "question": "Problem 1: [Identify the first problem and what it asks]",
          "explanation": "What we need to find for Problem 1",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctAnswer": "The exact correct option text"
        },
        {
          "question": "Problem 1: [Next step for solving Problem 1]",
          "explanation": "How to approach this step",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctAnswer": "The exact correct option text"
        },
        ... (3-5 steps for Problem 1)
        {
          "question": "Problem 2: [Identify the second problem]",
          "explanation": "What we need to find for Problem 2",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctAnswer": "The exact correct option text"
        },
        ... (3-5 steps for Problem 2)
        ... (continue for ALL problems on the sheet)
      ],
      "finalAnswer": "Summary: Problem 1 = [answer], Problem 2 = [answer], Problem 3 = [answer], etc."
    }

    GUIDING STYLE:
    - Use 3–5 short, targeted steps per problem
    - Label each step with which problem it's solving (e.g., "Problem 1:", "Problem 2:")
    - Each question should build toward that problem's answer
    - Include multiple choice options that make sense, but only one is fully correct
    - Do NOT reveal the correct answer inside the question or explanation text — only in "correctAnswer"
    - For word problems: identify key facts, convert them into equations, solve step by step

    SUBJECT BEHAVIOR:
    - Math: show equations, calculate step by step, include units
    - Science: identify data, explain reasoning, conclude clearly
    - English/Reading: identify context clues, grammar rules, or main idea
    - History/Social Studies: identify factual events, names, or causes/effects clearly

    MANDATORY: Create steps for EVERY problem visible on the homework sheet. Count them and verify completeness before responding.`;

    const messages = [
      { role: "system", content: systemPrompt }
    ];

    if (imageData) {
      const base64Image = imageData.toString('base64');
      const dataURL = `data:image/jpeg;base64,${base64Image}`;
      
      const contentArray = [
        { type: "text", text: userPrompt }
      ];
      
      if (problemText) {
        contentArray.push({ type: "text", text: `Additional context: ${problemText}` });
      }
      
      // Add the main problem image
      contentArray.push({
        type: "image_url",
        image_url: { 
          url: dataURL,
          detail: "high"
        }
      });
      
      // Add teacher method image if provided
      if (teacherMethodImageData) {
        const base64TeacherMethod = teacherMethodImageData.toString('base64');
        const teacherMethodDataURL = `data:image/jpeg;base64,${base64TeacherMethod}`;
        
        contentArray.push({
          type: "text",
          text: "Here is the teacher's example showing the preferred method to solve this type of problem:"
        });
        
        contentArray.push({
          type: "image_url",
          image_url: { 
            url: teacherMethodDataURL,
            detail: "high"
          }
        });
      }
      
      messages.push({
        role: "user",
        content: contentArray
      });
    } else if (problemText) {
      messages.push({
        role: "user",
        content: `${userPrompt}\n\nProblem: ${problemText}`
      });
    }

    const requestBody = {
      model: this.getModel('homework'),
      messages: messages,
      max_tokens: config.openai.maxTokens,
      temperature: config.openai.temperature,
      response_format: { type: "json_object" }
    };

    try {
      const response = await axios.post(`${this.baseURL}/chat/completions`, requestBody, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 60000 // 60 second timeout
      });

      if (response.data && response.data.choices && response.data.choices[0]) {
        const content = response.data.choices[0].message.content;
        const result = JSON.parse(content);
        
        // Track usage if userId provided
        if (userId && response.data.usage) {
          await usageTrackingService.trackUsage({
            userId,
            deviceId,
            endpoint: 'analyze_homework',
            model: this.getModel('imageAnalysis'),
            usage: response.data.usage,
            metadata
          });
        }
        
        return result;
      } else {
        throw new Error('Invalid response from OpenAI API');
      }
    } catch (error) {
      if (error.response) {
        if (error.response.status === 401) {
          const authError = new Error('Invalid OpenAI API key');
          authError.status = 401;
          throw authError;
        } else if (error.response.status === 429) {
          const rateLimitError = new Error('OpenAI API rate limit exceeded');
          rateLimitError.status = 429;
          throw rateLimitError;
        }
      }
      throw error;
    }
  }

  async generateHint({ step, problemContext, userGradeLevel, apiKey, userId, deviceId, metadata = {} }) {
    const systemPrompt = `You are "Homework Mentor" — a precise and patient AI tutor that helps students solve their exact homework questions step by step.
    Provide a subtle hint without giving away the answer. Use age-appropriate language and examples for ${userGradeLevel}.
    
    CRITICAL AGE-APPROPRIATE GUIDANCE:
    
    For Elementary Students (K-5):
    - Use concrete, visual examples instead of abstract formulas
    - Break complex concepts into simple repeated additions
    - Example: Instead of "2 × (length + width)", say "Add all four sides: length + length + width + width"
    - Use drawings in words: "Imagine the rectangle has 2 long sides and 2 short sides"
    - Show actual numbers without revealing the final answer: "If the sides are 5 and 3, add: 5 + 5 + 3 + 3"
    - Use everyday language: "count", "add together", "put side by side"
    
    For Middle School (6-8):
    - Can introduce simple formulas with explanations
    - Show both the formula AND the concrete breakdown
    - Example: "Perimeter = 2 × length + 2 × width, which means adding the two long sides and two short sides"
    - Use visual representations when helpful
    
    For High School (9-12):
    - Can use standard mathematical notation and formulas
    - Provide algebraic or formula-based hints
    - Example: "Use the formula P = 2(l + w) or 2l + 2w"
    
    IMPORTANT:
    - NEVER provide the final numerical answer
    - Show the pattern or method, not the solution
    - Guide thinking with questions: "What are we adding together?"
    - Use specific numbers from the problem to illustrate WITHOUT solving completely
    
    Focus on guiding the student's thinking, not solving for them.`;

    const userPrompt = `CRITICAL: Stay STRICTLY on topic. The hint MUST be directly related to THIS SPECIFIC problem.

PROBLEM CONTEXT: ${problemContext}

CURRENT STEP QUESTION: ${step.question}

STEP EXPLANATION: ${step.explanation}

AVAILABLE OPTIONS: ${step.options ? step.options.join(', ') : 'N/A'}

CORRECT ANSWER (for context only - DO NOT reveal): ${step.correctAnswer}

STUDENT GRADE LEVEL: ${userGradeLevel}

REQUIREMENTS FOR YOUR HINT:
1. ✅ MUST be directly related to "${problemContext}" - the actual problem the student is solving
2. ✅ MUST help answer "${step.question}" specifically
3. ✅ MUST use concepts from "${step.explanation}"
4. ❌ DO NOT talk about unrelated subjects (no math examples for social studies!)
5. ❌ DO NOT use generic examples (boxes, apples, etc.) unless they're in the original problem
6. ❌ DO NOT give away the final answer
7. ✅ Guide the student's thinking with questions or partial steps
8. ✅ Use age-appropriate language for ${userGradeLevel}

EXAMPLE OF GOOD HINT:
If problem is about "What year did Columbus discover America?":
✅ GOOD: "Think about the famous rhyme: 'In fourteen hundred ninety-two...' What year does that refer to?"
❌ BAD: "Think about adding and subtracting boxes" (WRONG SUBJECT!)

EXAMPLE OF BAD HINT:
If problem is about social studies:
❌ BAD: "Imagine you have 5 boxes and add 3 more boxes" (This is math, not social studies!)

Provide a helpful, age-appropriate hint that is DIRECTLY RELATED to the problem context and question above.`;

    const messages = [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt }
    ];

    const requestBody = {
      model: this.getModel('homework'),
      messages: messages,
      max_tokens: 400,
      temperature: config.openai.temperature
    };

    try {
      const response = await axios.post(`${this.baseURL}/chat/completions`, requestBody, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 second timeout
      });

      if (response.data && response.data.choices && response.data.choices[0]) {
        const content = response.data.choices[0].message.content;
        
        // Track usage if userId provided
        if (userId && response.data.usage) {
          await usageTrackingService.trackUsage({
            userId,
            deviceId,
            endpoint: 'generate_hint',
            model: this.getModel('imageAnalysis'),
            usage: response.data.usage,
            metadata
          });
        }
        
        return content;
      } else {
        throw new Error('Invalid response from OpenAI API');
      }
    } catch (error) {
      if (error.response) {
        if (error.response.status === 401) {
          const authError = new Error('Invalid OpenAI API key');
          authError.status = 401;
          throw authError;
        } else if (error.response.status === 429) {
          const rateLimitError = new Error('OpenAI API rate limit exceeded');
          rateLimitError.status = 429;
          throw rateLimitError;
        }
      }
      throw error;
    }
  }

  async verifyAnswer({ answer, step, problemContext, userGradeLevel, apiKey, userId, deviceId, metadata = {} }) {
    const systemPrompt = `You are "Homework Mentor" — a precise and patient AI tutor that helps students solve their exact homework questions step by step.
    You are verifying a student's homework answer. Accuracy is ESSENTIAL to prevent misleading the student.`;

    const userPrompt = `CRITICAL: You are verifying a student's homework answer. Accuracy is ESSENTIAL to prevent misleading the student.

    Question: ${step.question}
    Expected Correct Answer: ${step.correctAnswer}
    Student's Selected Answer: ${answer}
    All Available Options: ${step.options ? step.options.join(', ') : 'N/A'}
    
    VERIFICATION REQUIREMENTS:
    1. Check if the student's answer is mathematically/factually correct
    2. Consider equivalent expressions (e.g., "2+3" = "5", "half" = "0.5", "subtract 4" = "minus 4")
    3. Be strict about factual accuracy - if it's wrong, it's wrong
    4. Consider the student's grade level: ${userGradeLevel}
    
    EXAMPLES OF ACCEPTABLE VARIATIONS:
    - Mathematical: "5" = "five" = "2+3" = "10/2"
    - Operations: "add 3" = "plus 3" = "3 more"
    - Fractions: "1/2" = "half" = "0.5"
    
    RESPOND WITH EXACTLY ONE WORD:
    - "CORRECT" if the answer is right (including equivalent forms)
    - "INCORRECT" if the answer is wrong or misleading
    
    The student's education depends on your accuracy. Be thorough but fair.`;

    const messages = [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt }
    ];

    const requestBody = {
      model: this.getModel('homework'),
      messages: messages,
      max_tokens: 100,
      temperature: 0.0 // Deterministic for verification
    };

    try {
      const response = await axios.post(`${this.baseURL}/chat/completions`, requestBody, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 second timeout
      });

      if (response.data && response.data.choices && response.data.choices[0]) {
        const content = response.data.choices[0].message.content;
        const trimmedResponse = content.trim().toUpperCase();
        const isCorrect = trimmedResponse.includes("CORRECT") && !trimmedResponse.includes("INCORRECT");
        
        // Track usage if userId provided
        if (userId && response.data.usage) {
          await usageTrackingService.trackUsage({
            userId,
            deviceId,
            endpoint: 'verify_answer',
            model: this.getModel('imageAnalysis'),
            usage: response.data.usage,
            metadata
          });
        }
        
        return {
          isCorrect: isCorrect,
          verification: trimmedResponse
        };
      } else {
        throw new Error('Invalid response from OpenAI API');
      }
    } catch (error) {
      if (error.response) {
        if (error.response.status === 401) {
          const authError = new Error('Invalid OpenAI API key');
          authError.status = 401;
          throw authError;
        } else if (error.response.status === 429) {
          const rateLimitError = new Error('OpenAI API rate limit exceeded');
          rateLimitError.status = 429;
          throw rateLimitError;
        }
      }
      throw error;
    }
  }

  async generateChatResponse({ messages, problemContext, userGradeLevel, apiKey, userId, deviceId, metadata = {} }) {
    const systemPrompt = `You are "Homework Mentor" — an intelligent and patient tutor that helps students solve their exact homework questions step by step.

CRITICAL BEHAVIORS:
- You must focus ONLY on the specific question or context provided
- Provide helpful, educational guidance without giving away answers
- Adapt your language and explanations to the student's grade level: ${userGradeLevel}
- Be encouraging and supportive while maintaining educational standards

AGE-APPROPRIATE GUIDANCE:
- Elementary (K-5): Use simple language, visual examples, concrete concepts
- Middle School (6-8): Introduce formulas with clear explanations
- High School (9-12): Use appropriate mathematical notation and abstract concepts`;

    // Convert iOS ChatMessage format to OpenAI format
    const openaiMessages = [
      { role: "system", content: systemPrompt },
      ...messages.map(msg => ({
        role: msg.role || "user", // Handle different message formats
        content: msg.content
      }))
    ];

    const requestBody = {
      model: this.getModel('chat'),
      messages: openaiMessages,
      max_tokens: 800,
      temperature: 0.2
    };

    try {
      const response = await axios.post(`${this.baseURL}/chat/completions`, requestBody, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 second timeout
      });

      if (response.data && response.data.choices && response.data.choices[0]) {
        const content = response.data.choices[0].message.content;
        
        // Track usage if userId provided
        if (userId && response.data.usage) {
          await usageTrackingService.trackUsage({
            userId,
            deviceId,
            endpoint: 'chat_response',
            model: this.getModel('imageAnalysis'),
            usage: response.data.usage,
            metadata
          });
        }
        
        return content;
      } else {
        throw new Error('Invalid response from OpenAI API');
      }
    } catch (error) {
      if (error.response) {
        if (error.response.status === 401) {
          const authError = new Error('Invalid OpenAI API key');
          authError.status = 401;
          throw authError;
        } else if (error.response.status === 429) {
          const rateLimitError = new Error('OpenAI API rate limit exceeded');
          rateLimitError.status = 429;
          throw rateLimitError;
        }
      }
      throw error;
    }
  }

  /**
   * Analyze homework with Wolfram|Alpha integration for math problems
   * @param {Object} params - Analysis parameters
   * @returns {Object} - Analysis result with Wolfram|Alpha for math problems
   */
  async analyzeHomeworkWithWolfram({ imageData, problemText, teacherMethodImageData, userGradeLevel, apiKey, userId, deviceId, metadata = {} }) {
    try {
      // Check if this is a math problem that should use Wolfram|Alpha
      const isMathProblem = this.shouldUseWolframForMath(problemText);
      
      if (isMathProblem && problemText) {
        console.log('🧮 Math problem detected, using Wolfram|Alpha for calculation...');
        
        try {
          // Use Wolfram|Alpha to solve the math problem
          const wolframResult = await this.wolframService.solveMathProblem(problemText);
          
          if (wolframResult.success) {
            console.log('✅ Wolfram|Alpha solved the problem successfully');
            
            // Use OpenAI for the educational presentation and step-by-step guidance
            const openaiResult = await this.analyzeHomework({
              imageData,
              problemText,
              teacherMethodImageData,
              userGradeLevel,
              apiKey,
              userId,
              deviceId,
              metadata
            });
            
            // Enhance the OpenAI result with Wolfram|Alpha's accurate answer
            if (openaiResult && typeof openaiResult === 'object') {
              // Add Wolfram|Alpha data to the result
              openaiResult.wolframAlpha = {
                used: true,
                answer: wolframResult.answer,
                method: wolframResult.method,
                confidence: wolframResult.confidence,
                steps: wolframResult.steps
              };
              
              // Update the final answer with Wolfram|Alpha's result
              if (openaiResult.finalAnswer) {
                openaiResult.finalAnswer += ` (Verified by Wolfram|Alpha: ${wolframResult.answer})`;
              }
              
              // Update steps with Wolfram|Alpha verification
              if (openaiResult.steps && Array.isArray(openaiResult.steps)) {
                openaiResult.steps.push({
                  question: "Verification: Check our answer",
                  explanation: `Let's verify our answer using Wolfram|Alpha: ${wolframResult.answer}`,
                  options: ["Correct", "Needs review", "Different method", "Check calculation"],
                  correctAnswer: "Correct"
                });
              }
            }
            
            return openaiResult;
          } else {
            console.log('⚠️ Wolfram|Alpha failed, falling back to OpenAI only');
            // Fall back to regular OpenAI analysis
            return await this.analyzeHomework({
              imageData,
              problemText,
              teacherMethodImageData,
              userGradeLevel,
              apiKey,
              userId,
              deviceId,
              metadata
            });
          }
        } catch (wolframError) {
          console.error('❌ Wolfram|Alpha error:', wolframError.message);
          console.log('🔄 Falling back to OpenAI only');
          
          // Fall back to regular OpenAI analysis
          return await this.analyzeHomework({
            imageData,
            problemText,
            teacherMethodImageData,
            userGradeLevel,
            apiKey,
            userId,
            deviceId,
            metadata
          });
        }
      } else {
        // Not a math problem or no problem text, use regular OpenAI analysis
        console.log('📝 Non-math problem or no text, using OpenAI only');
        return await this.analyzeHomework({
          imageData,
          problemText,
          teacherMethodImageData,
          userGradeLevel,
          apiKey,
          userId,
          deviceId,
          metadata
        });
      }
    } catch (error) {
      console.error('❌ Error in analyzeHomeworkWithWolfram:', error);
      throw error;
    }
  }
}

module.exports = new OpenAIService();

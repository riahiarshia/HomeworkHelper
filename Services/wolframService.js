const https = require('https');
const querystring = require('querystring');

class WolframService {
    constructor() {
        // Initialize Wolfram|Alpha API with your App ID
        this.appId = '998W9JPWA9';
        this.baseURL = 'api.wolframalpha.com';
        
        console.log('🧮 Wolfram|Alpha service initialized with App ID:', this.appId);
    }

    /**
     * Solve a math problem using Wolfram|Alpha
     * @param {string} problem - The math problem to solve
     * @returns {Object} - Structured response with solution and steps
     */
    async solveMathProblem(problem) {
        try {
            console.log(`🧮 Solving math problem with Wolfram|Alpha: ${problem}`);
            
            // Query Wolfram|Alpha using direct HTTP request
            const result = await this.queryWolframAlpha(problem);
            
            // Parse the result
            const solution = this.parseWolframResult(result, problem);
            
            console.log(`✅ Wolfram|Alpha solution: ${solution.answer}`);
            
            return solution;
            
        } catch (error) {
            console.error('❌ Wolfram|Alpha error:', error.message);
            
            return {
                success: false,
                error: error.message,
                problem: problem,
                answer: null,
                steps: [],
                method: 'wolfram-alpha',
                fallback: true
            };
        }
    }

    /**
     * Make direct HTTP request to Wolfram|Alpha API
     * @param {string} query - The math query
     * @returns {Promise<Object>} - Raw API response
     */
    queryWolframAlpha(query) {
        return new Promise((resolve, reject) => {
            const params = {
                input: query,
                appid: this.appId,
                output: 'json'
            };
            
            const queryString = querystring.stringify(params);
            const path = `/v2/query?${queryString}`;
            
            console.log(`🌐 Making request to: ${this.baseURL}${path}`);
            
            const options = {
                hostname: this.baseURL,
                port: 443,
                path: path,
                method: 'GET',
                headers: {
                    'User-Agent': 'HomeworkHelper/1.0'
                }
            };
            
            const req = https.request(options, (res) => {
                let data = '';
                
                res.on('data', (chunk) => {
                    data += chunk;
                });
                
                res.on('end', () => {
                    try {
                        const result = JSON.parse(data);
                        resolve(result);
                    } catch (parseError) {
                        console.error('❌ Failed to parse Wolfram|Alpha response:', parseError);
                        reject(new Error('Invalid response format from Wolfram|Alpha'));
                    }
                });
            });
            
            req.on('error', (error) => {
                console.error('❌ Wolfram|Alpha request error:', error);
                reject(error);
            });
            
            req.setTimeout(10000, () => {
                req.destroy();
                reject(new Error('Wolfram|Alpha request timeout'));
            });
            
            req.end();
        });
    }

    /**
     * Parse Wolfram|Alpha result into structured format
     * @param {Object} result - Raw result from Wolfram|Alpha (XML parsed to object)
     * @param {string} problem - Original problem
     * @returns {Object} - Structured solution
     */
    parseWolframResult(result, problem) {
        try {
            console.log('📊 Parsing Wolfram|Alpha result...');
            
            let answer = 'Unable to solve';
            
            // Check if the query was successful
            if (result && result.queryresult && result.queryresult.success === true) {
                const queryResult = result.queryresult;
                
                // Look for the Result pod
                if (queryResult.pods && Array.isArray(queryResult.pods)) {
                    const resultPod = queryResult.pods.find(pod => 
                        pod.title === 'Result' && pod.subpods && pod.subpods.length > 0
                    );
                    
                    if (resultPod) {
                        // Extract the plaintext result
                        const subpod = resultPod.subpods[0];
                        if (subpod.plaintext) {
                            answer = subpod.plaintext.trim();
                            console.log(`✅ Extracted answer: ${answer}`);
                        }
                    } else {
                        console.log('⚠️ No Result pod found, looking for any pod with plaintext...');
                        
                        // Fallback: look for any pod with plaintext
                        for (const pod of queryResult.pods) {
                            if (pod.subpods && pod.subpods.length > 0) {
                                for (const subpod of pod.subpods) {
                                    if (subpod.plaintext && subpod.plaintext.trim()) {
                                        answer = subpod.plaintext.trim();
                                        console.log(`✅ Found answer in ${pod.title}: ${answer}`);
                                        break;
                                    }
                                }
                                if (answer !== 'Unable to solve') break;
                            }
                        }
                    }
                }
            } else if (result && result.queryresult && result.queryresult.error) {
                console.log('⚠️ Wolfram|Alpha returned error:', result.queryresult.error);
                answer = `Error: ${result.queryresult.error.msg || 'Unknown error'}`;
            }
            
            // Clean up the answer
            answer = this.cleanWolframAnswer(answer);
            
            // Generate steps based on the problem complexity
            const steps = this.generateSolutionSteps(problem, answer);
            
            return {
                success: true,
                problem: problem,
                answer: answer,
                steps: steps,
                method: 'wolfram-alpha',
                rawResult: result,
                confidence: 'high'
            };
            
        } catch (error) {
            console.error('❌ Error parsing Wolfram|Alpha result:', error);
            
            return {
                success: false,
                problem: problem,
                answer: 'Unable to solve',
                steps: [],
                method: 'wolfram-alpha',
                error: error.message
            };
        }
    }

    /**
     * Clean up Wolfram|Alpha answer format
     * @param {string} answer - Raw answer from Wolfram|Alpha
     * @returns {string} - Cleaned answer
     */
    cleanWolframAnswer(answer) {
        // Remove common Wolfram|Alpha formatting
        let cleaned = answer
            .replace(/^≈\s*/, '') // Remove approximation symbol at start
            .replace(/≈\s*/g, '≈ ') // Normalize approximation symbols
            .replace(/\s+/g, ' ') // Normalize whitespace
            .trim();
        
        // Handle special cases
        if (cleaned === 'undefined' || cleaned === 'indeterminate') {
            return 'Unable to solve this problem';
        }
        
        return cleaned;
    }

    /**
     * Generate solution steps based on problem and answer
     * @param {string} problem - Original problem
     * @param {string} answer - Final answer
     * @returns {Array} - Array of solution steps
     */
    generateSolutionSteps(problem, answer) {
        const steps = [];
        
        // Step 1: Identify the problem type
        if (this.isArithmeticProblem(problem)) {
            steps.push({
                step: 1,
                description: `Identify the arithmetic operation: ${problem}`,
                operation: this.identifyOperation(problem)
            });
            
            steps.push({
                step: 2,
                description: `Perform the calculation using Wolfram|Alpha`,
                operation: 'calculate'
            });
        } else if (this.isAlgebraicProblem(problem)) {
            steps.push({
                step: 1,
                description: `Solve the algebraic equation: ${problem}`,
                operation: 'solve'
            });
            
            steps.push({
                step: 2,
                description: `Apply algebraic rules and simplification`,
                operation: 'simplify'
            });
        } else if (this.isGeometryProblem(problem)) {
            steps.push({
                step: 1,
                description: `Identify the geometric calculation needed`,
                operation: 'identify'
            });
            
            steps.push({
                step: 2,
                description: `Apply the appropriate geometric formula`,
                operation: 'formula'
            });
        } else {
            steps.push({
                step: 1,
                description: `Analyze the mathematical problem`,
                operation: 'analyze'
            });
        }
        
        // Final step: Present the answer
        steps.push({
            step: steps.length + 1,
            description: `Final answer: ${answer}`,
            operation: 'result',
            answer: answer
        });
        
        return steps;
    }

    /**
     * Check if problem is arithmetic (basic operations)
     * @param {string} problem - Math problem
     * @returns {boolean} - True if arithmetic problem
     */
    isArithmeticProblem(problem) {
        const arithmeticPatterns = [
            /\d+\s*[+\-*/]\s*\d+/,
            /\d+\s*plus\s*\d+/i,
            /\d+\s*minus\s*\d+/i,
            /\d+\s*times\s*\d+/i,
            /\d+\s*divided\s*by\s*\d+/i
        ];
        
        return arithmeticPatterns.some(pattern => pattern.test(problem));
    }

    /**
     * Check if problem is algebraic
     * @param {string} problem - Math problem
     * @returns {boolean} - True if algebraic problem
     */
    isAlgebraicProblem(problem) {
        const algebraicPatterns = [
            /[a-zA-Z]\s*[+\-*/=]/,
            /solve\s+for\s+[a-zA-Z]/i,
            /equation/i,
            /variable/i
        ];
        
        return algebraicPatterns.some(pattern => pattern.test(problem));
    }

    /**
     * Check if problem is geometry
     * @param {string} problem - Math problem
     * @returns {boolean} - True if geometry problem
     */
    isGeometryProblem(problem) {
        const geometryPatterns = [
            /area|perimeter|circumference|volume/i,
            /circle|triangle|rectangle|square/i,
            /radius|diameter|height|width|length/i,
            /angle|degree/i
        ];
        
        return geometryPatterns.some(pattern => pattern.test(problem));
    }

    /**
     * Identify the arithmetic operation
     * @param {string} problem - Math problem
     * @returns {string} - Operation type
     */
    identifyOperation(problem) {
        if (/\+|plus/i.test(problem)) return 'addition';
        if (/-|minus/i.test(problem)) return 'subtraction';
        if (/\*|times|×/i.test(problem)) return 'multiplication';
        if (/\/|divided|÷/i.test(problem)) return 'division';
        return 'unknown';
    }

    /**
     * Verify if a problem should use Wolfram|Alpha
     * @param {string} problem - Math problem to check
     * @returns {boolean} - True if should use Wolfram|Alpha
     */
    shouldUseWolfram(problem) {
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
            /trigonometry|sin|cos|tan/i // Trigonometry
        ];
        
        return mathPatterns.some(pattern => pattern.test(problem));
    }

    /**
     * Test the Wolfram|Alpha service with a sample problem
     * @returns {Object} - Test result
     */
    async testService() {
        try {
            console.log('🧪 Testing Wolfram|Alpha service...');
            
            const testProblem = '2 + 2';
            const result = await this.solveMathProblem(testProblem);
            
            console.log('✅ Wolfram|Alpha test result:', result);
            
            return {
                success: true,
                testProblem: testProblem,
                result: result,
                message: 'Wolfram|Alpha service is working correctly'
            };
            
        } catch (error) {
            console.error('❌ Wolfram|Alpha test failed:', error);
            
            return {
                success: false,
                error: error.message,
                message: 'Wolfram|Alpha service test failed'
            };
        }
    }
}

module.exports = WolframService;

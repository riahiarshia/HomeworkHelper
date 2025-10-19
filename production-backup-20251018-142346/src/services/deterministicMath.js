const math = require('mathjs');

/**
 * Deterministic Math Service
 * Provides local mathematical calculations to validate and correct OpenAI responses
 */

/**
 * Normalizes units to standard form
 * @param {string} unitString - The unit string to normalize
 * @returns {string} - Normalized unit string
 */
function normalizeUnits(unitString) {
  if (!unitString || typeof unitString !== 'string') {
    return '';
  }
  
  const unitMap = {
    // Length units
    'meters': 'm',
    'metres': 'm',
    'meter': 'm',
    'metre': 'm',
    'centimeters': 'cm',
    'centimetres': 'cm',
    'centimeter': 'cm',
    'centimetre': 'cm',
    'millimeters': 'mm',
    'millimetres': 'mm',
    'millimeter': 'mm',
    'millimetre': 'mm',
    'kilometers': 'km',
    'kilometres': 'km',
    'kilometer': 'km',
    'kilometre': 'km',
    'inches': 'in',
    'inch': 'in',
    'feet': 'ft',
    'foot': 'ft',
    'yards': 'yd',
    'yard': 'yd',
    'miles': 'mi',
    'mile': 'mi',
    
    // Area units
    'square meters': 'm²',
    'square metres': 'm²',
    'square meter': 'm²',
    'square metre': 'm²',
    'square centimeters': 'cm²',
    'square centimetres': 'cm²',
    'square feet': 'ft²',
    'square foot': 'ft²',
    'square inches': 'in²',
    'square inch': 'in²',
    
    // Volume units
    'cubic meters': 'm³',
    'cubic metres': 'm³',
    'cubic meter': 'm³',
    'cubic metre': 'm³',
    'liters': 'L',
    'litres': 'L',
    'liter': 'L',
    'litre': 'L',
    'milliliters': 'mL',
    'millilitres': 'mL',
    'milliliter': 'mL',
    'millilitre': 'mL',
    'gallons': 'gal',
    'gallon': 'gal',
    'quarts': 'qt',
    'quart': 'qt',
    'pints': 'pt',
    'pint': 'pt',
    
    // Weight/Mass units
    'kilograms': 'kg',
    'kilogram': 'kg',
    'grams': 'g',
    'gram': 'g',
    'pounds': 'lb',
    'pound': 'lb',
    'ounces': 'oz',
    'ounce': 'oz',
    
    // Time units
    'seconds': 's',
    'second': 's',
    'minutes': 'min',
    'minute': 'min',
    'hours': 'h',
    'hour': 'h',
    'days': 'd',
    'day': 'd',
    
    // Temperature units
    'celsius': '°C',
    'fahrenheit': '°F',
    'kelvin': 'K',
    
    // Other common units
    'degrees': '°',
    'radians': 'rad',
    'radian': 'rad'
  };
  
  const lowerUnit = unitString.toLowerCase().trim();
  return unitMap[lowerUnit] || unitString;
}

/**
 * Builds an expected string from a value and units
 * @param {number|string} value - The calculated value
 * @param {string} units - The units (optional)
 * @returns {string} - Formatted expected string
 */
function buildExpectedString(value, units = '') {
  if (units && units.trim()) {
    return `${value} ${units}`;
  }
  return String(value);
}

/**
 * Evaluates a mathematical calculation from a step object
 * @param {Object} step - The step object containing calc information
 * @returns {Object|null} - { value, units, expected } or null if can't evaluate
 */
function evaluateCalc(step) {
  if (!step || !step.calc || !step.calc.expression) {
    return null;
  }
  
  try {
    const { expression, expectedUnits = '', inputs = {} } = step.calc;
    
    // Create a scope with input variables
    const scope = { ...inputs };
    
    // Evaluate the expression
    const result = math.evaluate(expression, scope);
    
    // Handle different result types
    let value;
    if (typeof result === 'number') {
      value = result;
    } else if (result && typeof result === 'object' && result.re !== undefined) {
      // Complex number
      if (result.im === 0) {
        value = result.re;
      } else {
        // Complex numbers not supported for simple math
        return null;
      }
    } else if (result && typeof result === 'object' && result.n !== undefined) {
      // Fraction
      value = result.n / result.d;
    } else {
      // Unsupported result type
      return null;
    }
    
    // Normalize units
    const normalizedUnits = normalizeUnits(expectedUnits);
    
    // Build expected string
    const expected = buildExpectedString(value, normalizedUnits);
    
    return {
      value,
      units: normalizedUnits,
      expected
    };
  } catch (error) {
    console.log('Math evaluation error:', error.message);
    return null;
  }
}

/**
 * Repairs a single step by correcting the correctAnswer if needed
 * @param {Object} step - The step object to repair
 * @returns {Object} - The repaired step object
 */
function repairStep(step) {
  if (!step || !step.calc) {
    return step;
  }
  
  const evaluation = evaluateCalc(step);
  if (evaluation && step.correctAnswer !== evaluation.expected) {
    console.log(`Repairing step: "${step.correctAnswer}" → "${evaluation.expected}"`);
    return {
      ...step,
      correctAnswer: evaluation.expected
    };
  }
  
  return step;
}

/**
 * Repairs multiple steps by correcting correctAnswer values
 * @param {Array} steps - Array of step objects to repair
 * @returns {Array} - Array of repaired step objects
 */
function repairSteps(steps) {
  if (!Array.isArray(steps)) {
    return steps;
  }
  
  return steps.map(repairStep);
}

/**
 * Verifies a student's answer against the calculated result
 * @param {Object} params - { answer, step }
 * @returns {Object} - { isCorrect: boolean, expected?: string }
 */
function verifyAnswer({ answer, step }) {
  if (!step || !step.calc) {
    return { isCorrect: false };
  }
  
  const evaluation = evaluateCalc(step);
  if (!evaluation) {
    return { isCorrect: false };
  }
  
  // Normalize the student's answer for comparison
  const normalizedAnswer = String(answer).trim().toLowerCase();
  const normalizedExpected = evaluation.expected.toLowerCase();
  
  // Check for exact match
  if (normalizedAnswer === normalizedExpected) {
    return { isCorrect: true };
  }
  
  // Check for numeric equivalence (handle different formats)
  try {
    const answerNum = parseFloat(normalizedAnswer);
    const expectedNum = parseFloat(normalizedExpected);
    
    if (!isNaN(answerNum) && !isNaN(expectedNum)) {
      // Allow small floating point differences
      if (Math.abs(answerNum - expectedNum) < 0.0001) {
        return { isCorrect: true };
      }
    }
  } catch (error) {
    // Ignore parsing errors, continue with string comparison
  }
  
  // Check for equivalent expressions (e.g., "2+3" = "5")
  try {
    const answerEval = math.evaluate(normalizedAnswer);
    const expectedEval = math.evaluate(normalizedExpected);
    
    if (typeof answerEval === 'number' && typeof expectedEval === 'number') {
      if (Math.abs(answerEval - expectedEval) < 0.0001) {
        return { isCorrect: true };
      }
    }
  } catch (error) {
    // Ignore evaluation errors
  }
  
  return {
    isCorrect: false,
    expected: evaluation.expected
  };
}

module.exports = {
  normalizeUnits,
  buildExpectedString,
  evaluateCalc,
  repairStep,
  repairSteps,
  verifyAnswer
};

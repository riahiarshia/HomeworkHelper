// Email validation
export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Password validation
export const isValidPassword = (password: string): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (password.length < 6) {
    errors.push('Password must be at least 6 characters long');
  }
  
  if (password.length > 128) {
    errors.push('Password must be less than 128 characters');
  }
  
  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Username validation
export const isValidUsername = (username: string): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (username.length < 3) {
    errors.push('Username must be at least 3 characters long');
  }
  
  if (username.length > 50) {
    errors.push('Username must be less than 50 characters');
  }
  
  const usernameRegex = /^[a-zA-Z0-9_-]+$/;
  if (!usernameRegex.test(username)) {
    errors.push('Username can only contain letters, numbers, underscores, and hyphens');
  }
  
  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Promo code validation
export const isValidPromoCode = (code: string): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (code.length < 3) {
    errors.push('Promo code must be at least 3 characters long');
  }
  
  if (code.length > 20) {
    errors.push('Promo code must be less than 20 characters');
  }
  
  const codeRegex = /^[A-Z0-9_-]+$/;
  if (!codeRegex.test(code)) {
    errors.push('Promo code can only contain uppercase letters, numbers, underscores, and hyphens');
  }
  
  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Number validation
export const isValidNumber = (value: string | number, min?: number, max?: number): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  const num = typeof value === 'string' ? parseFloat(value) : value;
  
  if (isNaN(num)) {
    errors.push('Must be a valid number');
    return { isValid: false, errors };
  }
  
  if (min !== undefined && num < min) {
    errors.push(`Must be at least ${min}`);
  }
  
  if (max !== undefined && num > max) {
    errors.push(`Must be at most ${max}`);
  }
  
  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Date validation
export const isValidDate = (dateString: string): boolean => {
  const date = new Date(dateString);
  return date instanceof Date && !isNaN(date.getTime());
};

export const isFutureDate = (dateString: string): boolean => {
  const date = new Date(dateString);
  return date > new Date();
};

// Form validation helpers
export const validateRequired = (value: any, fieldName: string): string | null => {
  if (value === null || value === undefined || value === '') {
    return `${fieldName} is required`;
  }
  return null;
};

export const validateEmail = (email: string, fieldName: string = 'Email'): string | null => {
  if (!email) return `${fieldName} is required`;
  if (!isValidEmail(email)) return `${fieldName} must be a valid email address`;
  return null;
};

export const validatePassword = (password: string, fieldName: string = 'Password'): string | null => {
  if (!password) return `${fieldName} is required`;
  const validation = isValidPassword(password);
  if (!validation.isValid) return validation.errors[0];
  return null;
};

export const validateConfirmPassword = (password: string, confirmPassword: string): string | null => {
  if (!confirmPassword) return 'Please confirm your password';
  if (password !== confirmPassword) return 'Passwords do not match';
  return null;
};

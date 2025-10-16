import { isValidEmail, isValidPassword, isValidUsername, validateEmail, validatePassword } from '../validation';

describe('validation utilities', () => {
  describe('isValidEmail', () => {
    it('should validate correct email formats', () => {
      expect(isValidEmail('test@example.com')).toBe(true);
      expect(isValidEmail('user.name@domain.co.uk')).toBe(true);
      expect(isValidEmail('test+tag@example.org')).toBe(true);
    });

    it('should reject invalid email formats', () => {
      expect(isValidEmail('invalid-email')).toBe(false);
      expect(isValidEmail('@example.com')).toBe(false);
      expect(isValidEmail('test@')).toBe(false);
      expect(isValidEmail('')).toBe(false);
    });
  });

  describe('isValidPassword', () => {
    it('should accept valid passwords', () => {
      const result = isValidPassword('password123');
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject short passwords', () => {
      const result = isValidPassword('123');
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Password must be at least 6 characters long');
    });

    it('should reject long passwords', () => {
      const longPassword = 'a'.repeat(129);
      const result = isValidPassword(longPassword);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Password must be less than 128 characters');
    });
  });

  describe('isValidUsername', () => {
    it('should accept valid usernames', () => {
      const result = isValidUsername('valid_user');
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject short usernames', () => {
      const result = isValidUsername('ab');
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Username must be at least 3 characters long');
    });

    it('should reject usernames with invalid characters', () => {
      const result = isValidUsername('user@name');
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Username can only contain letters, numbers, underscores, and hyphens');
    });
  });

  describe('validateEmail', () => {
    it('should return null for valid email', () => {
      expect(validateEmail('test@example.com')).toBeNull();
    });

    it('should return error for invalid email', () => {
      expect(validateEmail('invalid')).toBe('Email must be a valid email address');
    });

    it('should return error for empty email', () => {
      expect(validateEmail('')).toBe('Email is required');
    });
  });

  describe('validatePassword', () => {
    it('should return null for valid password', () => {
      expect(validatePassword('password123')).toBeNull();
    });

    it('should return error for invalid password', () => {
      expect(validatePassword('123')).toBe('Password must be at least 6 characters long');
    });

    it('should return error for empty password', () => {
      expect(validatePassword('')).toBe('Password is required');
    });
  });
});

import { formatDate, formatNumber, formatCurrency, getSubscriptionBadgeClass } from '../format';

describe('format utilities', () => {
  describe('formatDate', () => {
    it('should format a valid date string', () => {
      const dateString = '2024-01-15T10:30:00Z';
      const result = formatDate(dateString);
      expect(result).toMatch(/\d{1,2}\/\d{1,2}\/\d{4}/);
    });

    it('should return "-" for null or undefined', () => {
      expect(formatDate(null)).toBe('-');
      expect(formatDate(undefined)).toBe('-');
    });

    it('should return "-" for invalid date string', () => {
      expect(formatDate('invalid-date')).toBe('-');
    });
  });

  describe('formatNumber', () => {
    it('should format positive numbers', () => {
      expect(formatNumber(1234)).toBe('1,234');
      expect(formatNumber(0)).toBe('0');
    });

    it('should handle null and undefined', () => {
      expect(formatNumber(null)).toBe('0');
      expect(formatNumber(undefined)).toBe('0');
    });
  });

  describe('formatCurrency', () => {
    it('should format currency values', () => {
      expect(formatCurrency(123.456)).toBe('$123.4560');
      expect(formatCurrency(0)).toBe('$0.0000');
    });

    it('should handle null and undefined', () => {
      expect(formatCurrency(null)).toBe('$0.00');
      expect(formatCurrency(undefined)).toBe('$0.00');
    });
  });

  describe('getSubscriptionBadgeClass', () => {
    it('should return correct classes for known statuses', () => {
      expect(getSubscriptionBadgeClass('active')).toBe('bg-success-100 text-success-800');
      expect(getSubscriptionBadgeClass('trial')).toBe('bg-blue-100 text-blue-800');
      expect(getSubscriptionBadgeClass('expired')).toBe('bg-danger-100 text-danger-800');
    });

    it('should return default classes for unknown status', () => {
      expect(getSubscriptionBadgeClass('unknown')).toBe('bg-gray-100 text-gray-800');
    });
  });
});

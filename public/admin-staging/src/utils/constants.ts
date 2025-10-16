// API endpoints
export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/admin-login',
    LOGOUT: '/auth/logout',
  },
  ADMIN: {
    STATS: '/admin/stats',
    USERS: '/admin/users',
    PROMO_CODES: '/admin/promo-codes',
    DEVICES: '/admin/devices',
    LEDGER: '/admin/ledger',
    AUDIT_LOG: '/admin/audit-log',
  },
  USAGE: {
    STATS: '/usage/stats',
    ENDPOINT: '/usage/endpoint',
    SUMMARY: '/usage/summary',
    EXPORT: '/usage/export',
  },
  SUBSCRIPTION: {
    EXTEND_TRIAL: '/subscription/admin/extend-trial',
  },
} as const;

// User subscription statuses
export const SUBSCRIPTION_STATUSES = {
  TRIAL: 'trial',
  ACTIVE: 'active',
  PROMO_ACTIVE: 'promo_active',
  EXPIRED: 'expired',
  CANCELLED: 'cancelled',
} as const;

// Auth providers
export const AUTH_PROVIDERS = {
  EMAIL: 'email',
  GOOGLE: 'google',
  APPLE: 'apple',
} as const;

// Risk levels
export const RISK_LEVELS = {
  LOW: 'Low',
  MEDIUM: 'Medium',
  HIGH: 'High',
} as const;

// Fraud flag severities
export const FRAUD_SEVERITIES = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
} as const;

// Notification types
export const NOTIFICATION_TYPES = {
  SUCCESS: 'success',
  ERROR: 'error',
  WARNING: 'warning',
  INFO: 'info',
} as const;

// Table page sizes
export const PAGE_SIZES = [10, 20, 50, 100] as const;
export const DEFAULT_PAGE_SIZE = 20;

// Date formats
export const DATE_FORMATS = {
  SHORT: 'MM/dd/yyyy',
  LONG: 'MMMM dd, yyyy',
  DATETIME: 'MM/dd/yyyy HH:mm:ss',
  ISO: 'yyyy-MM-dd',
} as const;

// Local storage keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: 'adminToken',
  THEME: 'theme',
  SIDEBAR_STATE: 'sidebarOpen',
} as const;

// Default values
export const DEFAULTS = {
  TRIAL_DAYS: 7,
  SUBSCRIPTION_DAYS: 30,
  PROMO_CODE_LENGTH: 10,
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
} as const;

// Error messages
export const ERROR_MESSAGES = {
  NETWORK_ERROR: 'Network error. Please check your connection.',
  UNAUTHORIZED: 'You are not authorized to perform this action.',
  FORBIDDEN: 'Access denied.',
  NOT_FOUND: 'The requested resource was not found.',
  SERVER_ERROR: 'Server error. Please try again later.',
  VALIDATION_ERROR: 'Please check your input and try again.',
  UNKNOWN_ERROR: 'An unknown error occurred.',
} as const;

// Success messages
export const SUCCESS_MESSAGES = {
  USER_CREATED: 'User created successfully.',
  USER_UPDATED: 'User updated successfully.',
  USER_DELETED: 'User deleted successfully.',
  PROMO_CODE_CREATED: 'Promo code created successfully.',
  PROMO_CODE_UPDATED: 'Promo code updated successfully.',
  PROMO_CODE_DELETED: 'Promo code deleted successfully.',
  PASSWORD_CHANGED: 'Password changed successfully.',
  SUBSCRIPTION_EXTENDED: 'Subscription extended successfully.',
} as const;

// Navigation items
export const NAVIGATION_ITEMS = [
  { id: 'dashboard', label: 'Dashboard', icon: 'BarChart3' },
  { id: 'users', label: 'Users', icon: 'Users' },
  { id: 'devices', label: 'Device Analytics', icon: 'Smartphone' },
  { id: 'promoCodes', label: 'Promo Codes', icon: 'Tag' },
  { id: 'apiUsage', label: 'API Usage', icon: 'Activity' },
  { id: 'ledger', label: 'Ledger', icon: 'Shield' },
  { id: 'auditLog', label: 'Audit Log', icon: 'FileText' },
] as const;

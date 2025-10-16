import {
  API_ENDPOINTS,
  SUBSCRIPTION_STATUS,
  AUTH_PROVIDERS,
  RISK_LEVELS,
  NOTIFICATION_TYPES,
  PAGE_SIZES,
  DATE_FORMATS,
  STORAGE_KEYS,
  DEFAULT_VALUES,
  ERROR_MESSAGES,
  SUCCESS_MESSAGES,
} from '../constants';

describe('Constants', () => {
  describe('API_ENDPOINTS', () => {
    it('has correct base URL', () => {
      expect(API_ENDPOINTS.BASE).toBe('/api');
    });

    it('has correct auth endpoints', () => {
      expect(API_ENDPOINTS.AUTH.LOGIN).toBe('/api/auth/login');
      expect(API_ENDPOINTS.AUTH.LOGOUT).toBe('/api/auth/logout');
      expect(API_ENDPOINTS.AUTH.VALIDATE).toBe('/api/auth/validate');
    });

    it('has correct admin endpoints', () => {
      expect(API_ENDPOINTS.ADMIN.DASHBOARD).toBe('/api/admin/dashboard');
      expect(API_ENDPOINTS.ADMIN.USERS).toBe('/api/admin/users');
      expect(API_ENDPOINTS.ADMIN.USER_DETAILS).toBe('/api/admin/users/:id');
      expect(API_ENDPOINTS.ADMIN.PROMO_CODES).toBe('/api/admin/promo-codes');
      expect(API_ENDPOINTS.ADMIN.DEVICES).toBe('/api/admin/devices');
      expect(API_ENDPOINTS.ADMIN.API_USAGE).toBe('/api/admin/api-usage');
      expect(API_ENDPOINTS.ADMIN.LEDGER).toBe('/api/admin/ledger');
      expect(API_ENDPOINTS.ADMIN.AUDIT_LOG).toBe('/api/admin/audit-log');
    });

    it('has correct subscription endpoints', () => {
      expect(API_ENDPOINTS.SUBSCRIPTIONS.SYNC).toBe('/api/subscriptions/sync');
      expect(API_ENDPOINTS.SUBSCRIPTIONS.STATUS).toBe('/api/subscriptions/status');
      expect(API_ENDPOINTS.SUBSCRIPTIONS.EXTEND).toBe('/api/subscriptions/extend');
    });

    it('has correct webhook endpoints', () => {
      expect(API_ENDPOINTS.WEBHOOKS.APPLE).toBe('/api/webhooks/apple');
      expect(API_ENDPOINTS.WEBHOOKS.STRIPE).toBe('/api/webhooks/stripe');
    });
  });

  describe('SUBSCRIPTION_STATUS', () => {
    it('has correct status values', () => {
      expect(SUBSCRIPTION_STATUS.ACTIVE).toBe('active');
      expect(SUBSCRIPTION_STATUS.INACTIVE).toBe('inactive');
      expect(SUBSCRIPTION_STATUS.TRIAL).toBe('trial');
      expect(SUBSCRIPTION_STATUS.EXPIRED).toBe('expired');
      expect(SUBSCRIPTION_STATUS.CANCELLED).toBe('cancelled');
      expect(SUBSCRIPTION_STATUS.PENDING).toBe('pending');
      expect(SUBSCRIPTION_STATUS.SUSPENDED).toBe('suspended');
    });

    it('has correct status labels', () => {
      expect(SUBSCRIPTION_STATUS.LABELS.ACTIVE).toBe('Active');
      expect(SUBSCRIPTION_STATUS.LABELS.INACTIVE).toBe('Inactive');
      expect(SUBSCRIPTION_STATUS.LABELS.TRIAL).toBe('Trial');
      expect(SUBSCRIPTION_STATUS.LABELS.EXPIRED).toBe('Expired');
      expect(SUBSCRIPTION_STATUS.LABELS.CANCELLED).toBe('Cancelled');
      expect(SUBSCRIPTION_STATUS.LABELS.PENDING).toBe('Pending');
      expect(SUBSCRIPTION_STATUS.LABELS.SUSPENDED).toBe('Suspended');
    });
  });

  describe('AUTH_PROVIDERS', () => {
    it('has correct provider values', () => {
      expect(AUTH_PROVIDERS.EMAIL).toBe('email');
      expect(AUTH_PROVIDERS.GOOGLE).toBe('google');
      expect(AUTH_PROVIDERS.APPLE).toBe('apple');
    });

    it('has correct provider labels', () => {
      expect(AUTH_PROVIDERS.LABELS.EMAIL).toBe('Email');
      expect(AUTH_PROVIDERS.LABELS.GOOGLE).toBe('Google');
      expect(AUTH_PROVIDERS.LABELS.APPLE).toBe('Apple');
    });
  });

  describe('RISK_LEVELS', () => {
    it('has correct risk level values', () => {
      expect(RISK_LEVELS.LOW).toBe('low');
      expect(RISK_LEVELS.MEDIUM).toBe('medium');
      expect(RISK_LEVELS.HIGH).toBe('high');
      expect(RISK_LEVELS.CRITICAL).toBe('critical');
    });

    it('has correct risk level labels', () => {
      expect(RISK_LEVELS.LABELS.LOW).toBe('Low');
      expect(RISK_LEVELS.LABELS.MEDIUM).toBe('Medium');
      expect(RISK_LEVELS.LABELS.HIGH).toBe('High');
      expect(RISK_LEVELS.LABELS.CRITICAL).toBe('Critical');
    });

    it('has correct risk level colors', () => {
      expect(RISK_LEVELS.COLORS.LOW).toBe('green');
      expect(RISK_LEVELS.COLORS.MEDIUM).toBe('yellow');
      expect(RISK_LEVELS.COLORS.HIGH).toBe('orange');
      expect(RISK_LEVELS.COLORS.CRITICAL).toBe('red');
    });
  });

  describe('NOTIFICATION_TYPES', () => {
    it('has correct notification type values', () => {
      expect(NOTIFICATION_TYPES.SUCCESS).toBe('success');
      expect(NOTIFICATION_TYPES.ERROR).toBe('error');
      expect(NOTIFICATION_TYPES.WARNING).toBe('warning');
      expect(NOTIFICATION_TYPES.INFO).toBe('info');
    });

    it('has correct notification type labels', () => {
      expect(NOTIFICATION_TYPES.LABELS.SUCCESS).toBe('Success');
      expect(NOTIFICATION_TYPES.LABELS.ERROR).toBe('Error');
      expect(NOTIFICATION_TYPES.LABELS.WARNING).toBe('Warning');
      expect(NOTIFICATION_TYPES.LABELS.INFO).toBe('Info');
    });
  });

  describe('PAGE_SIZES', () => {
    it('has correct page size values', () => {
      expect(PAGE_SIZES.SMALL).toBe(10);
      expect(PAGE_SIZES.MEDIUM).toBe(25);
      expect(PAGE_SIZES.LARGE).toBe(50);
      expect(PAGE_SIZES.XLARGE).toBe(100);
    });

    it('has correct default page size', () => {
      expect(PAGE_SIZES.DEFAULT).toBe(25);
    });
  });

  describe('DATE_FORMATS', () => {
    it('has correct date format values', () => {
      expect(DATE_FORMATS.DATE).toBe('YYYY-MM-DD');
      expect(DATE_FORMATS.DATETIME).toBe('YYYY-MM-DD HH:mm:ss');
      expect(DATE_FORMATS.TIME).toBe('HH:mm:ss');
      expect(DATE_FORMATS.DISPLAY).toBe('MMM DD, YYYY');
      expect(DATE_FORMATS.DISPLAY_DATETIME).toBe('MMM DD, YYYY HH:mm');
    });
  });

  describe('STORAGE_KEYS', () => {
    it('has correct storage key values', () => {
      expect(STORAGE_KEYS.AUTH_TOKEN).toBe('auth_token');
      expect(STORAGE_KEYS.USER_DATA).toBe('user_data');
      expect(STORAGE_KEYS.THEME).toBe('theme');
      expect(STORAGE_KEYS.LANGUAGE).toBe('language');
      expect(STORAGE_KEYS.SIDEBAR_STATE).toBe('sidebar_state');
    });
  });

  describe('DEFAULT_VALUES', () => {
    it('has correct default values', () => {
      expect(DEFAULT_VALUES.PAGE_SIZE).toBe(25);
      expect(DEFAULT_VALUES.PAGE_NUMBER).toBe(1);
      expect(DEFAULT_VALUES.SEARCH_DEBOUNCE).toBe(300);
      expect(DEFAULT_VALUES.NOTIFICATION_DURATION).toBe(5000);
      expect(DEFAULT_VALUES.THEME).toBe('light');
      expect(DEFAULT_VALUES.LANGUAGE).toBe('en');
    });
  });

  describe('ERROR_MESSAGES', () => {
    it('has correct error messages', () => {
      expect(ERROR_MESSAGES.GENERIC).toBe('Something went wrong. Please try again.');
      expect(ERROR_MESSAGES.NETWORK).toBe('Network error. Please check your connection.');
      expect(ERROR_MESSAGES.UNAUTHORIZED).toBe('You are not authorized to perform this action.');
      expect(ERROR_MESSAGES.FORBIDDEN).toBe('Access denied.');
      expect(ERROR_MESSAGES.NOT_FOUND).toBe('The requested resource was not found.');
      expect(ERROR_MESSAGES.VALIDATION).toBe('Please check your input and try again.');
      expect(ERROR_MESSAGES.SERVER_ERROR).toBe('Server error. Please try again later.');
    });

    it('has correct auth error messages', () => {
      expect(ERROR_MESSAGES.AUTH.INVALID_CREDENTIALS).toBe('Invalid email or password.');
      expect(ERROR_MESSAGES.AUTH.TOKEN_EXPIRED).toBe('Your session has expired. Please log in again.');
      expect(ERROR_MESSAGES.AUTH.ACCOUNT_LOCKED).toBe('Your account has been locked.');
      expect(ERROR_MESSAGES.AUTH.ACCOUNT_DISABLED).toBe('Your account has been disabled.');
    });

    it('has correct user error messages', () => {
      expect(ERROR_MESSAGES.USER.NOT_FOUND).toBe('User not found.');
      expect(ERROR_MESSAGES.USER.ALREADY_EXISTS).toBe('User already exists.');
      expect(ERROR_MESSAGES.USER.INVALID_EMAIL).toBe('Invalid email address.');
      expect(ERROR_MESSAGES.USER.INVALID_PASSWORD).toBe('Password must be at least 8 characters long.');
    });

    it('has correct subscription error messages', () => {
      expect(ERROR_MESSAGES.SUBSCRIPTION.NOT_FOUND).toBe('Subscription not found.');
      expect(ERROR_MESSAGES.SUBSCRIPTION.ALREADY_ACTIVE).toBe('Subscription is already active.');
      expect(ERROR_MESSAGES.SUBSCRIPTION.EXPIRED).toBe('Subscription has expired.');
      expect(ERROR_MESSAGES.SUBSCRIPTION.CANCELLED).toBe('Subscription has been cancelled.');
    });
  });

  describe('SUCCESS_MESSAGES', () => {
    it('has correct success messages', () => {
      expect(SUCCESS_MESSAGES.GENERIC).toBe('Operation completed successfully.');
      expect(SUCCESS_MESSAGES.SAVED).toBe('Changes saved successfully.');
      expect(SUCCESS_MESSAGES.DELETED).toBe('Item deleted successfully.');
      expect(SUCCESS_MESSAGES.CREATED).toBe('Item created successfully.');
      expect(SUCCESS_MESSAGES.UPDATED).toBe('Item updated successfully.');
    });

    it('has correct auth success messages', () => {
      expect(SUCCESS_MESSAGES.AUTH.LOGIN).toBe('Login successful.');
      expect(SUCCESS_MESSAGES.AUTH.LOGOUT).toBe('Logout successful.');
      expect(SUCCESS_MESSAGES.AUTH.PASSWORD_CHANGED).toBe('Password changed successfully.');
    });

    it('has correct user success messages', () => {
      expect(SUCCESS_MESSAGES.USER.CREATED).toBe('User created successfully.');
      expect(SUCCESS_MESSAGES.USER.UPDATED).toBe('User updated successfully.');
      expect(SUCCESS_MESSAGES.USER.DELETED).toBe('User deleted successfully.');
      expect(SUCCESS_MESSAGES.USER.ACTIVATED).toBe('User activated successfully.');
      expect(SUCCESS_MESSAGES.USER.DEACTIVATED).toBe('User deactivated successfully.');
    });

    it('has correct subscription success messages', () => {
      expect(SUCCESS_MESSAGES.SUBSCRIPTION.CREATED).toBe('Subscription created successfully.');
      expect(SUCCESS_MESSAGES.SUBSCRIPTION.UPDATED).toBe('Subscription updated successfully.');
      expect(SUCCESS_MESSAGES.SUBSCRIPTION.CANCELLED).toBe('Subscription cancelled successfully.');
      expect(SUCCESS_MESSAGES.SUBSCRIPTION.RENEWED).toBe('Subscription renewed successfully.');
    });
  });

  describe('Constants structure', () => {
    it('has all required top-level constants', () => {
      expect(API_ENDPOINTS).toBeDefined();
      expect(SUBSCRIPTION_STATUS).toBeDefined();
      expect(AUTH_PROVIDERS).toBeDefined();
      expect(RISK_LEVELS).toBeDefined();
      expect(NOTIFICATION_TYPES).toBeDefined();
      expect(PAGE_SIZES).toBeDefined();
      expect(DATE_FORMATS).toBeDefined();
      expect(STORAGE_KEYS).toBeDefined();
      expect(DEFAULT_VALUES).toBeDefined();
      expect(ERROR_MESSAGES).toBeDefined();
      expect(SUCCESS_MESSAGES).toBeDefined();
    });

    it('has correct API endpoints structure', () => {
      expect(API_ENDPOINTS.BASE).toBeDefined();
      expect(API_ENDPOINTS.AUTH).toBeDefined();
      expect(API_ENDPOINTS.ADMIN).toBeDefined();
      expect(API_ENDPOINTS.SUBSCRIPTIONS).toBeDefined();
      expect(API_ENDPOINTS.WEBHOOKS).toBeDefined();
    });

    it('has correct subscription status structure', () => {
      expect(SUBSCRIPTION_STATUS.ACTIVE).toBeDefined();
      expect(SUBSCRIPTION_STATUS.INACTIVE).toBeDefined();
      expect(SUBSCRIPTION_STATUS.TRIAL).toBeDefined();
      expect(SUBSCRIPTION_STATUS.EXPIRED).toBeDefined();
      expect(SUBSCRIPTION_STATUS.CANCELLED).toBeDefined();
      expect(SUBSCRIPTION_STATUS.PENDING).toBeDefined();
      expect(SUBSCRIPTION_STATUS.SUSPENDED).toBeDefined();
      expect(SUBSCRIPTION_STATUS.LABELS).toBeDefined();
    });

    it('has correct auth providers structure', () => {
      expect(AUTH_PROVIDERS.EMAIL).toBeDefined();
      expect(AUTH_PROVIDERS.GOOGLE).toBeDefined();
      expect(AUTH_PROVIDERS.APPLE).toBeDefined();
      expect(AUTH_PROVIDERS.LABELS).toBeDefined();
    });

    it('has correct risk levels structure', () => {
      expect(RISK_LEVELS.LOW).toBeDefined();
      expect(RISK_LEVELS.MEDIUM).toBeDefined();
      expect(RISK_LEVELS.HIGH).toBeDefined();
      expect(RISK_LEVELS.CRITICAL).toBeDefined();
      expect(RISK_LEVELS.LABELS).toBeDefined();
      expect(RISK_LEVELS.COLORS).toBeDefined();
    });

    it('has correct notification types structure', () => {
      expect(NOTIFICATION_TYPES.SUCCESS).toBeDefined();
      expect(NOTIFICATION_TYPES.ERROR).toBeDefined();
      expect(NOTIFICATION_TYPES.WARNING).toBeDefined();
      expect(NOTIFICATION_TYPES.INFO).toBeDefined();
      expect(NOTIFICATION_TYPES.LABELS).toBeDefined();
    });

    it('has correct page sizes structure', () => {
      expect(PAGE_SIZES.SMALL).toBeDefined();
      expect(PAGE_SIZES.MEDIUM).toBeDefined();
      expect(PAGE_SIZES.LARGE).toBeDefined();
      expect(PAGE_SIZES.XLARGE).toBeDefined();
      expect(PAGE_SIZES.DEFAULT).toBeDefined();
    });

    it('has correct date formats structure', () => {
      expect(DATE_FORMATS.DATE).toBeDefined();
      expect(DATE_FORMATS.DATETIME).toBeDefined();
      expect(DATE_FORMATS.TIME).toBeDefined();
      expect(DATE_FORMATS.DISPLAY).toBeDefined();
      expect(DATE_FORMATS.DISPLAY_DATETIME).toBeDefined();
    });

    it('has correct storage keys structure', () => {
      expect(STORAGE_KEYS.AUTH_TOKEN).toBeDefined();
      expect(STORAGE_KEYS.USER_DATA).toBeDefined();
      expect(STORAGE_KEYS.THEME).toBeDefined();
      expect(STORAGE_KEYS.LANGUAGE).toBeDefined();
      expect(STORAGE_KEYS.SIDEBAR_STATE).toBeDefined();
    });

    it('has correct default values structure', () => {
      expect(DEFAULT_VALUES.PAGE_SIZE).toBeDefined();
      expect(DEFAULT_VALUES.PAGE_NUMBER).toBeDefined();
      expect(DEFAULT_VALUES.SEARCH_DEBOUNCE).toBeDefined();
      expect(DEFAULT_VALUES.NOTIFICATION_DURATION).toBeDefined();
      expect(DEFAULT_VALUES.THEME).toBeDefined();
      expect(DEFAULT_VALUES.LANGUAGE).toBeDefined();
    });

    it('has correct error messages structure', () => {
      expect(ERROR_MESSAGES.GENERIC).toBeDefined();
      expect(ERROR_MESSAGES.NETWORK).toBeDefined();
      expect(ERROR_MESSAGES.UNAUTHORIZED).toBeDefined();
      expect(ERROR_MESSAGES.FORBIDDEN).toBeDefined();
      expect(ERROR_MESSAGES.NOT_FOUND).toBeDefined();
      expect(ERROR_MESSAGES.VALIDATION).toBeDefined();
      expect(ERROR_MESSAGES.SERVER_ERROR).toBeDefined();
      expect(ERROR_MESSAGES.AUTH).toBeDefined();
      expect(ERROR_MESSAGES.USER).toBeDefined();
      expect(ERROR_MESSAGES.SUBSCRIPTION).toBeDefined();
    });

    it('has correct success messages structure', () => {
      expect(SUCCESS_MESSAGES.GENERIC).toBeDefined();
      expect(SUCCESS_MESSAGES.SAVED).toBeDefined();
      expect(SUCCESS_MESSAGES.DELETED).toBeDefined();
      expect(SUCCESS_MESSAGES.CREATED).toBeDefined();
      expect(SUCCESS_MESSAGES.UPDATED).toBeDefined();
      expect(SUCCESS_MESSAGES.AUTH).toBeDefined();
      expect(SUCCESS_MESSAGES.USER).toBeDefined();
      expect(SUCCESS_MESSAGES.SUBSCRIPTION).toBeDefined();
    });
  });
});
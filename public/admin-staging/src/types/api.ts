// API Response types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  totalPages: number;
  totalItems: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface PaginatedResponse<T> {
  items: T[];
  pagination: PaginationMeta;
}

// Common entity types
export interface User {
  user_id: string;
  email: string;
  username?: string;
  subscription_status: 'trial' | 'active' | 'promo_active' | 'expired' | 'cancelled';
  subscription_start_date?: string;
  subscription_end_date?: string;
  days_remaining: number;
  is_active: boolean;
  is_banned: boolean;
  promo_code_used?: string;
  auth_provider: 'email' | 'google' | 'apple';
  total_logins: number;
  logins_last_7_days: number;
  unique_devices: number;
  last_login?: string;
  created_at: string;
  updated_at?: string;
}

export interface PromoCode {
  id: number;
  code: string;
  duration_days: number;
  used_count: number;
  uses_total: number;
  active: boolean;
  description?: string;
  expires_at?: string;
  created_at: string;
}

export interface DeviceAnalytics {
  device_id: string;
  device_name?: string;
  user_count: number;
  total_logins: number;
  first_seen: string;
  last_seen: string;
  users: DeviceUser[];
}

export interface DeviceUser {
  user_id: string;
  email: string;
  username?: string;
  subscription_status: string;
  is_active: boolean;
  auth_provider: string;
  login_count: number;
  last_login: string;
}

export interface FraudFlag {
  id: string;
  user_id: string;
  device_id: string;
  reason: string;
  severity: 'low' | 'medium' | 'high';
  created_at: string;
}

export interface UsageStats {
  overall: {
    total_api_calls: number;
    total_tokens: number;
    total_cost: number;
    total_users: number;
  };
  daily: {
    daily_api_calls: number;
    daily_tokens: number;
    daily_cost: number;
  };
  monthly: {
    monthly_users: number;
  };
}

export interface EndpointUsage {
  endpoint: string;
  model: string;
  api_calls: number;
  total_tokens: number;
  avg_tokens_per_call: number;
  cost_usd: number;
  avg_cost_per_call: number;
}

export interface UserUsage {
  user_id: string;
  email: string;
  username?: string;
  device_id?: string;
  subscription_status: string;
  cycle_calls: number;
  cycle_tokens: number;
  cycle_cost: number;
  total_tokens: number;
  total_cost: number;
}

export interface LedgerStats {
  total_records: number;
  trial_count: number;
  active_count: number;
  expired_count: number;
}

export interface LedgerRecord {
  id: string;
  hash_preview: string;
  product_id: string;
  subscription_group_id: string;
  ever_trial: boolean;
  status: 'active' | 'expired';
  first_seen_at: string;
  last_seen_at: string;
  days_since_last_seen: number;
}

export interface UserEntitlement {
  id: string;
  user_id: string;
  email: string;
  username?: string;
  hash_preview: string;
  product_id: string;
  is_trial: boolean;
  status: 'active' | 'expired';
  expires_at?: string;
  days_remaining: number;
}

export interface AuditLogRecord {
  id: string;
  admin_username: string;
  admin_email: string;
  action: string;
  target_user_id?: string;
  target_username?: string;
  target_email?: string;
  details: string;
  ip_address?: string;
  created_at: string;
}

export interface DashboardStats {
  total_users: number;
  active_subscriptions: number;
  trial_users: number;
  expired_subscriptions: number;
}

// Form types
export interface CreateUserForm {
  email: string;
  password: string;
  subscription_status: 'trial' | 'active' | 'promo_active';
  subscription_days: number;
}

export interface CreatePromoCodeForm {
  code: string;
  duration_days: number;
  uses_total?: number;
  description?: string;
  expires_at?: string;
}

export interface ChangePasswordForm {
  new_password: string;
  confirm_password: string;
}

export interface EditMembershipForm {
  subscription_status?: string;
  subscription_start_date?: string;
  subscription_end_date?: string;
}

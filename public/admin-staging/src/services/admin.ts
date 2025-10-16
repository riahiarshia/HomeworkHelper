import { apiClient } from './api';
import type {
  DashboardStats,
  User,
  PromoCode,
  DeviceAnalytics,
  FraudFlag,
  UsageStats,
  EndpointUsage,
  UserUsage,
  LedgerStats,
  LedgerRecord,
  UserEntitlement,
  AuditLogRecord,
  CreateUserForm,
  CreatePromoCodeForm,
  ChangePasswordForm,
  EditMembershipForm,
  PaginatedResponse,
} from '@/types/api';

export const adminService = {
  // Dashboard
  async getDashboardStats(): Promise<DashboardStats> {
    return apiClient.get<DashboardStats>('/admin/stats');
  },

  // Users
  async getUsers(params?: {
    page?: number;
    limit?: number;
    search?: string;
    status?: string;
  }): Promise<PaginatedResponse<User>> {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.search) queryParams.append('search', params.search);
    if (params?.status) queryParams.append('status', params.status);

    const response = await apiClient.get<{ users: User[]; pagination: any }>(
      `/admin/users?${queryParams}`
    );
    
    return {
      items: response.users,
      pagination: response.pagination,
    };
  },

  async getUserById(userId: string): Promise<{ user: User; subscription_history: any[] }> {
    return apiClient.get(`/admin/users/${userId}`);
  },

  async createUser(userData: CreateUserForm): Promise<{ success: boolean; message: string }> {
    return apiClient.post('/admin/users', userData);
  },

  async updateUser(userId: string, updates: Partial<User>): Promise<{ success: boolean; message: string }> {
    return apiClient.put(`/admin/users/${userId}`, updates);
  },

  async deleteUser(userId: string): Promise<{ success: boolean; message: string }> {
    return apiClient.delete(`/admin/users/${userId}`);
  },

  async toggleUserAccess(userId: string, isActive: boolean): Promise<{ success: boolean; message: string }> {
    return apiClient.post(`/admin/users/${userId}/toggle-access`, { is_active: isActive });
  },

  async banUser(userId: string, isBanned: boolean, reason?: string): Promise<{ success: boolean; message: string }> {
    return apiClient.post(`/admin/users/${userId}/ban`, { is_banned: isBanned, reason });
  },

  async extendUserSubscription(userId: string, days: number): Promise<{ success: boolean; message: string }> {
    return apiClient.post(`/admin/users/${userId}/extend`, { days });
  },

  async changeUserPassword(userId: string, passwordData: ChangePasswordForm): Promise<{ success: boolean; message: string }> {
    return apiClient.put(`/admin/users/${userId}/password`, { new_password: passwordData.new_password });
  },

  async updateUserMembership(userId: string, membershipData: EditMembershipForm): Promise<{ success: boolean; message: string }> {
    return apiClient.put(`/admin/users/${userId}/membership`, membershipData);
  },

  // Promo Codes
  async getPromoCodes(): Promise<{ promo_codes: PromoCode[] }> {
    return apiClient.get('/admin/promo-codes');
  },

  async createPromoCode(promoData: CreatePromoCodeForm): Promise<{ success: boolean; message: string }> {
    return apiClient.post('/admin/promo-codes', promoData);
  },

  async updatePromoCode(codeId: number, updates: Partial<PromoCode>): Promise<{ success: boolean; message: string }> {
    return apiClient.put(`/admin/promo-codes/${codeId}`, updates);
  },

  async deletePromoCode(codeId: number): Promise<{ success: boolean; message: string }> {
    return apiClient.delete(`/admin/promo-codes/${codeId}`);
  },

  // Device Analytics
  async getDeviceAnalytics(): Promise<{ success: boolean; data: DeviceAnalytics[] }> {
    return apiClient.get('/admin/devices/shared-details');
  },

  async getFraudFlags(): Promise<{ success: boolean; data: FraudFlag[] }> {
    return apiClient.get('/admin/devices/fraud-flags?unresolved=true');
  },

  // API Usage
  async getUsageStats(): Promise<{ data: UsageStats }> {
    return apiClient.get('/usage/stats');
  },

  async getEndpointUsage(): Promise<{ data: EndpointUsage[] }> {
    return apiClient.get('/usage/endpoint');
  },

  async getUserUsage(params?: {
    limit?: number;
    sortBy?: string;
    order?: 'ASC' | 'DESC';
  }): Promise<{ data: { users: UserUsage[] } }> {
    const queryParams = new URLSearchParams();
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sortBy) queryParams.append('sortBy', params.sortBy);
    if (params?.order) queryParams.append('order', params.order);

    return apiClient.get(`/usage/summary?${queryParams}`);
  },

  async getUserCycleStats(userId: string): Promise<{ data: any }> {
    return apiClient.get(`/usage/user/${userId}/cycle-stats`);
  },

  async exportUsageData(type: 'summary' | 'detailed'): Promise<Blob> {
    const endpoint = type === 'summary' ? '/usage/export/summary' : '/usage/export';
    const response = await fetch(`${apiClient['baseURL']}${endpoint}`, {
      headers: {
        'Authorization': `Bearer ${apiClient['token']}`,
      },
    });
    
    if (!response.ok) {
      throw new Error('Failed to export data');
    }
    
    return response.blob();
  },

  // Ledger
  async getLedgerStats(): Promise<{ success: boolean; ledger: LedgerStats }> {
    return apiClient.get('/admin/ledger/stats');
  },

  async getLedgerRecords(params?: {
    page?: number;
    limit?: number;
    filter?: string;
  }): Promise<{ success: boolean; records: LedgerRecord[]; pagination: any }> {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.filter) queryParams.append('filter', params.filter);

    return apiClient.get(`/admin/ledger/records?${queryParams}`);
  },

  async getUserEntitlements(params?: {
    page?: number;
    limit?: number;
  }): Promise<{ success: boolean; records: UserEntitlement[] }> {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());

    return apiClient.get(`/admin/ledger/user-entitlements?${queryParams}`);
  },

  // Audit Log
  async getAuditLog(params?: {
    page?: number;
    limit?: number;
    action?: string;
  }): Promise<{ success: boolean; records: AuditLogRecord[]; pagination: any }> {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.action) queryParams.append('action', params.action);

    return apiClient.get(`/admin/audit-log?${queryParams}`);
  },

  // Trial Management
  async extendTrial(userId: string, days: number): Promise<{ success: boolean; subscription: any }> {
    return apiClient.post('/subscription/admin/extend-trial', { userId, days });
  },
};

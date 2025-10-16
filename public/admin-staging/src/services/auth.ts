import { apiClient } from './api';
import type { LoginCredentials, LoginResponse } from '@/types/auth';

export const authService = {
  async login(credentials: LoginCredentials): Promise<LoginResponse> {
    return apiClient.post<LoginResponse>('/auth/admin-login', credentials);
  },

  async logout(): Promise<void> {
    apiClient.setToken(null);
  },

  async validateSession(): Promise<boolean> {
    try {
      await apiClient.get('/admin/stats');
      return true;
    } catch {
      return false;
    }
  },
};

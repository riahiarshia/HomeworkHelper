import { adminService } from '../admin';
import { apiClient } from '../api';

// Mock the API client
jest.mock('../api');
const mockApiClient = apiClient as jest.Mocked<typeof apiClient>;

describe('admin service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getDashboardStats', () => {
    it('fetches dashboard stats successfully', async () => {
      const mockStats = {
        total_users: 150,
        active_subscriptions: 120,
        trial_users: 25,
        expired_subscriptions: 5,
      };

      mockApiClient.get.mockResolvedValue(mockStats);

      const result = await adminService.getDashboardStats();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/stats');
      expect(result).toEqual(mockStats);
    });
  });

  describe('getUsers', () => {
    it('fetches users with default parameters', async () => {
      const mockResponse = {
        users: [
          {
            user_id: 'user-1',
            email: 'test@example.com',
            username: 'testuser',
            subscription_status: 'active',
            days_remaining: 15,
            is_active: true,
            is_banned: false,
            auth_provider: 'email',
            total_logins: 25,
            logins_last_7_days: 5,
            unique_devices: 2,
            created_at: '2024-01-01',
          },
        ],
        pagination: {
          page: 1,
          limit: 20,
          totalPages: 1,
          totalItems: 1,
          hasNext: false,
          hasPrev: false,
        },
      };

      mockApiClient.get.mockResolvedValue(mockResponse);

      const result = await adminService.getUsers();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/users?');
      expect(result).toEqual({
        items: mockResponse.users,
        pagination: mockResponse.pagination,
      });
    });

    it('fetches users with custom parameters', async () => {
      const mockResponse = {
        users: [],
        pagination: {
          page: 2,
          limit: 10,
          totalPages: 5,
          totalItems: 50,
          hasNext: true,
          hasPrev: true,
        },
      };

      mockApiClient.get.mockResolvedValue(mockResponse);

      const result = await adminService.getUsers({
        page: 2,
        limit: 10,
        search: 'test',
        status: 'active',
      });

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/users?page=2&limit=10&search=test&status=active');
      expect(result).toEqual({
        items: mockResponse.users,
        pagination: mockResponse.pagination,
      });
    });
  });

  describe('createUser', () => {
    it('creates a new user successfully', async () => {
      const userData = {
        email: 'newuser@example.com',
        password: 'password123',
        subscription_status: 'trial' as const,
        subscription_days: 7,
      };

      const mockResponse = {
        success: true,
        message: 'User created successfully',
      };

      mockApiClient.post.mockResolvedValue(mockResponse);

      const result = await adminService.createUser(userData);

      expect(mockApiClient.post).toHaveBeenCalledWith('/admin/users', userData);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('updateUser', () => {
    it('updates user successfully', async () => {
      const userId = 'user-1';
      const updates = {
        subscription_status: 'active' as const,
        days_remaining: 30,
      };

      const mockResponse = {
        success: true,
        message: 'User updated successfully',
      };

      mockApiClient.put.mockResolvedValue(mockResponse);

      const result = await adminService.updateUser(userId, updates);

      expect(mockApiClient.put).toHaveBeenCalledWith(`/admin/users/${userId}`, updates);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('deleteUser', () => {
    it('deletes user successfully', async () => {
      const userId = 'user-1';
      const mockResponse = {
        success: true,
        message: 'User deleted successfully',
      };

      mockApiClient.delete.mockResolvedValue(mockResponse);

      const result = await adminService.deleteUser(userId);

      expect(mockApiClient.delete).toHaveBeenCalledWith(`/admin/users/${userId}`);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('toggleUserAccess', () => {
    it('toggles user access successfully', async () => {
      const userId = 'user-1';
      const isActive = false;
      const mockResponse = {
        success: true,
        message: 'User access updated successfully',
      };

      mockApiClient.post.mockResolvedValue(mockResponse);

      const result = await adminService.toggleUserAccess(userId, isActive);

      expect(mockApiClient.post).toHaveBeenCalledWith(`/admin/users/${userId}/toggle-access`, {
        is_active: isActive,
      });
      expect(result).toEqual(mockResponse);
    });
  });

  describe('banUser', () => {
    it('bans user successfully', async () => {
      const userId = 'user-1';
      const isBanned = true;
      const reason = 'Violation of terms';
      const mockResponse = {
        success: true,
        message: 'User banned successfully',
      };

      mockApiClient.post.mockResolvedValue(mockResponse);

      const result = await adminService.banUser(userId, isBanned, reason);

      expect(mockApiClient.post).toHaveBeenCalledWith(`/admin/users/${userId}/ban`, {
        is_banned: isBanned,
        reason,
      });
      expect(result).toEqual(mockResponse);
    });
  });

  describe('extendUserSubscription', () => {
    it('extends user subscription successfully', async () => {
      const userId = 'user-1';
      const days = 30;
      const mockResponse = {
        success: true,
        message: 'Subscription extended successfully',
      };

      mockApiClient.post.mockResolvedValue(mockResponse);

      const result = await adminService.extendUserSubscription(userId, days);

      expect(mockApiClient.post).toHaveBeenCalledWith(`/admin/users/${userId}/extend`, {
        days,
      });
      expect(result).toEqual(mockResponse);
    });
  });

  describe('getPromoCodes', () => {
    it('fetches promo codes successfully', async () => {
      const mockResponse = {
        promo_codes: [
          {
            id: 1,
            code: 'SAVE20',
            duration_days: 30,
            used_count: 5,
            uses_total: 100,
            active: true,
            description: '20% off for 30 days',
            expires_at: '2024-12-31',
            created_at: '2024-01-01',
          },
        ],
      };

      mockApiClient.get.mockResolvedValue(mockResponse);

      const result = await adminService.getPromoCodes();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/promo-codes');
      expect(result).toEqual(mockResponse);
    });
  });

  describe('createPromoCode', () => {
    it('creates promo code successfully', async () => {
      const promoData = {
        code: 'NEWCODE',
        duration_days: 15,
        uses_total: 50,
        description: 'New promo code',
      };

      const mockResponse = {
        success: true,
        message: 'Promo code created successfully',
      };

      mockApiClient.post.mockResolvedValue(mockResponse);

      const result = await adminService.createPromoCode(promoData);

      expect(mockApiClient.post).toHaveBeenCalledWith('/admin/promo-codes', promoData);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('getLedgerStats', () => {
    it('fetches ledger stats successfully', async () => {
      const mockResponse = {
        success: true,
        ledger: {
          total_records: 1000,
          trial_count: 200,
          active_count: 700,
          expired_count: 100,
        },
      };

      mockApiClient.get.mockResolvedValue(mockResponse);

      const result = await adminService.getLedgerStats();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/ledger/stats');
      expect(result).toEqual(mockResponse);
    });
  });

  describe('getAuditLog', () => {
    it('fetches audit log successfully', async () => {
      const mockResponse = {
        success: true,
        records: [
          {
            id: 'log-1',
            admin_username: 'admin',
            admin_email: 'admin@test.com',
            action: 'USER_CREATED',
            target_user_id: 'user-1',
            target_username: 'testuser',
            target_email: 'test@example.com',
            details: 'User created with trial subscription',
            ip_address: '192.168.1.1',
            created_at: '2024-01-15T10:30:00Z',
          },
        ],
        pagination: {
          page: 1,
          limit: 20,
          totalPages: 5,
          totalItems: 100,
          hasNext: true,
          hasPrev: false,
        },
      };

      mockApiClient.get.mockResolvedValue(mockResponse);

      const result = await adminService.getAuditLog();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/audit-log?');
      expect(result).toEqual(mockResponse);
    });

    it('fetches audit log with filters', async () => {
      const mockResponse = {
        success: true,
        records: [],
        pagination: {
          page: 2,
          limit: 10,
          totalPages: 1,
          totalItems: 0,
          hasNext: false,
          hasPrev: true,
        },
      };

      mockApiClient.get.mockResolvedValue(mockResponse);

      const result = await adminService.getAuditLog({
        page: 2,
        limit: 10,
        action: 'USER_CREATED',
      });

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/audit-log?page=2&limit=10&action=USER_CREATED');
      expect(result).toEqual(mockResponse);
    });
  });
});
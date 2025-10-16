import { authService } from '../auth';
import { apiClient } from '../api';

// Mock the API client
jest.mock('../api');
const mockApiClient = apiClient as jest.Mocked<typeof apiClient>;

describe('auth service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('login', () => {
    it('logs in successfully', async () => {
      const credentials = {
        username: 'admin',
        password: 'password123',
      };

      const mockResponse = {
        token: 'jwt-token-here',
        admin: {
          id: '1',
          username: 'admin',
          email: 'admin@test.com',
        },
      };

      mockApiClient.post.mockResolvedValue(mockResponse);

      const result = await authService.login(credentials);

      expect(mockApiClient.post).toHaveBeenCalledWith('/auth/admin-login', credentials);
      expect(result).toEqual(mockResponse);
    });

    it('handles login failure', async () => {
      const credentials = {
        username: 'admin',
        password: 'wrong-password',
      };

      const mockError = new Error('Invalid credentials');
      mockApiClient.post.mockRejectedValue(mockError);

      await expect(authService.login(credentials)).rejects.toThrow('Invalid credentials');
      expect(mockApiClient.post).toHaveBeenCalledWith('/auth/admin-login', credentials);
    });
  });

  describe('logout', () => {
    it('logs out successfully', async () => {
      mockApiClient.setToken.mockResolvedValue(undefined);

      await authService.logout();

      expect(mockApiClient.setToken).toHaveBeenCalledWith(null);
    });
  });

  describe('validateSession', () => {
    it('validates session successfully', async () => {
      mockApiClient.get.mockResolvedValue({});

      const result = await authService.validateSession();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/stats');
      expect(result).toBe(true);
    });

    it('handles validation failure', async () => {
      const mockError = new Error('Unauthorized');
      mockApiClient.get.mockRejectedValue(mockError);

      const result = await authService.validateSession();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/stats');
      expect(result).toBe(false);
    });

    it('handles network error during validation', async () => {
      const mockError = new Error('Network error');
      mockApiClient.get.mockRejectedValue(mockError);

      const result = await authService.validateSession();

      expect(mockApiClient.get).toHaveBeenCalledWith('/admin/stats');
      expect(result).toBe(false);
    });
  });
});
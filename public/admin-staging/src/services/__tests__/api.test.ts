import { apiClient } from '../api';

// Mock fetch
global.fetch = jest.fn();
const mockFetch = fetch as jest.MockedFunction<typeof fetch>;

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
});

describe('API client', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    localStorageMock.getItem.mockReturnValue(null);
  });

  describe('GET requests', () => {
    it('makes successful GET request', async () => {
      const mockData = { message: 'Success' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      const result = await apiClient.get('/test');

      expect(mockFetch).toHaveBeenCalledWith('/api/test', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });
      expect(result).toEqual(mockData);
    });

    it('includes authorization header when token is present', async () => {
      const mockToken = 'jwt-token';
      localStorageMock.getItem.mockReturnValue(mockToken);
      
      const mockData = { message: 'Success' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      await apiClient.get('/test');

      expect(mockFetch).toHaveBeenCalledWith('/api/test', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${mockToken}`,
        },
      });
    });

    it('handles 401 unauthorized response', async () => {
      const mockResponse = {
        ok: false,
        status: 401,
        text: jest.fn().mockResolvedValue('Unauthorized'),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      await expect(apiClient.get('/test')).rejects.toThrow('Unauthorized');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('adminToken');
    });

    it('handles non-ok response', async () => {
      const mockResponse = {
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
        text: jest.fn().mockResolvedValue('Server error'),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      await expect(apiClient.get('/test')).rejects.toThrow('Server error');
    });

    it('handles network error', async () => {
      const networkError = new Error('Network error');
      mockFetch.mockRejectedValue(networkError);

      await expect(apiClient.get('/test')).rejects.toThrow('Network error');
    });
  });

  describe('POST requests', () => {
    it('makes successful POST request with data', async () => {
      const requestData = { name: 'Test' };
      const mockData = { id: 1, name: 'Test' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      const result = await apiClient.post('/test', requestData);

      expect(mockFetch).toHaveBeenCalledWith('/api/test', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData),
      });
      expect(result).toEqual(mockData);
    });

    it('makes POST request without data', async () => {
      const mockData = { message: 'Success' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      const result = await apiClient.post('/test');

      expect(mockFetch).toHaveBeenCalledWith('/api/test', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: undefined,
      });
      expect(result).toEqual(mockData);
    });
  });

  describe('PUT requests', () => {
    it('makes successful PUT request', async () => {
      const requestData = { name: 'Updated' };
      const mockData = { id: 1, name: 'Updated' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      const result = await apiClient.put('/test/1', requestData);

      expect(mockFetch).toHaveBeenCalledWith('/api/test/1', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData),
      });
      expect(result).toEqual(mockData);
    });
  });

  describe('DELETE requests', () => {
    it('makes successful DELETE request', async () => {
      const mockData = { message: 'Deleted' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      const result = await apiClient.delete('/test/1');

      expect(mockFetch).toHaveBeenCalledWith('/api/test/1', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        },
      });
      expect(result).toEqual(mockData);
    });
  });

  describe('PATCH requests', () => {
    it('makes successful PATCH request', async () => {
      const requestData = { status: 'active' };
      const mockData = { id: 1, status: 'active' };
      const mockResponse = {
        ok: true,
        json: jest.fn().mockResolvedValue(mockData),
      };
      mockFetch.mockResolvedValue(mockResponse as any);

      const result = await apiClient.patch('/test/1', requestData);

      expect(mockFetch).toHaveBeenCalledWith('/api/test/1', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData),
      });
      expect(result).toEqual(mockData);
    });
  });

  describe('token management', () => {
    it('sets token correctly', () => {
      const token = 'new-token';
      apiClient.setToken(token);

      expect(localStorageMock.setItem).toHaveBeenCalledWith('adminToken', token);
    });

    it('removes token when set to null', () => {
      apiClient.setToken(null);

      expect(localStorageMock.removeItem).toHaveBeenCalledWith('adminToken');
    });
  });
});
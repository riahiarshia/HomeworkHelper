import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from '../auth';
import { authService } from '@/services/auth';

// Mock the auth service
jest.mock('@/services/auth');
const mockAuthService = authService as jest.Mocked<typeof authService>;

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

describe('auth store', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    localStorageMock.getItem.mockReturnValue(null);
  });

  it('initializes with default state', () => {
    const { result } = renderHook(() => useAuthStore());
    
    expect(result.current.admin).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });

  it('loads state from localStorage on initialization', () => {
    const mockToken = 'mock-token';
    const mockAdmin = { id: '1', username: 'admin', email: 'admin@test.com' };
    
    localStorageMock.getItem.mockImplementation((key) => {
      if (key === 'adminToken') return mockToken;
      if (key === 'adminUser') return JSON.stringify(mockAdmin);
      return null;
    });

    const { result } = renderHook(() => useAuthStore());
    
    expect(result.current.token).toBe(mockToken);
    expect(result.current.admin).toEqual(mockAdmin);
    expect(result.current.isAuthenticated).toBe(true);
  });

  it('handles login successfully', async () => {
    const mockResponse = {
      token: 'new-token',
      admin: { id: '1', username: 'admin', email: 'admin@test.com' },
    };
    
    mockAuthService.login.mockResolvedValue(mockResponse);

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      await result.current.login('admin', 'password');
    });

    expect(result.current.token).toBe('new-token');
    expect(result.current.admin).toEqual(mockResponse.admin);
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.isLoading).toBe(false);
  });

  it('handles login failure', async () => {
    const mockError = new Error('Invalid credentials');
    mockAuthService.login.mockRejectedValue(mockError);

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      try {
        await result.current.login('admin', 'wrong-password');
      } catch (error) {
        expect(error).toBe(mockError);
      }
    });

    expect(result.current.token).toBeNull();
    expect(result.current.admin).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });

  it('handles logout', async () => {
    const { result } = renderHook(() => useAuthStore());

    // Set initial state
    act(() => {
      result.current.token = 'mock-token';
      result.current.admin = { id: '1', username: 'admin', email: 'admin@test.com' };
      result.current.isAuthenticated = true;
    });

    await act(async () => {
      await result.current.logout();
    });

    expect(result.current.token).toBeNull();
    expect(result.current.admin).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(mockAuthService.logout).toHaveBeenCalled();
  });

  it('validates session successfully', async () => {
    mockAuthService.validateSession.mockResolvedValue(true);

    const { result } = renderHook(() => useAuthStore());

    let isValid: boolean;
    await act(async () => {
      isValid = await result.current.validateSession();
    });

    expect(isValid!).toBe(true);
    expect(result.current.isAuthenticated).toBe(true);
  });

  it('validates session failure', async () => {
    mockAuthService.validateSession.mockResolvedValue(false);

    const { result } = renderHook(() => useAuthStore());

    let isValid: boolean;
    await act(async () => {
      isValid = await result.current.validateSession();
    });

    expect(isValid!).toBe(false);
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('handles session validation error', async () => {
    mockAuthService.validateSession.mockRejectedValue(new Error('Network error'));

    const { result } = renderHook(() => useAuthStore());

    let isValid: boolean;
    await act(async () => {
      isValid = await result.current.validateSession();
    });

    expect(isValid!).toBe(false);
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('sets loading state during login', async () => {
    mockAuthService.login.mockImplementation(() => new Promise(() => {})); // Never resolves

    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.login('admin', 'password');
    });

    expect(result.current.isLoading).toBe(true);
  });

  it('persists state to localStorage on login', async () => {
    const mockResponse = {
      token: 'new-token',
      admin: { id: '1', username: 'admin', email: 'admin@test.com' },
    };
    
    mockAuthService.login.mockResolvedValue(mockResponse);

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      await result.current.login('admin', 'password');
    });

    expect(localStorageMock.setItem).toHaveBeenCalledWith('adminToken', 'new-token');
    expect(localStorageMock.setItem).toHaveBeenCalledWith('adminUser', JSON.stringify(mockResponse.admin));
  });

  it('clears localStorage on logout', async () => {
    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      await result.current.logout();
    });

    expect(localStorageMock.removeItem).toHaveBeenCalledWith('adminToken');
    expect(localStorageMock.removeItem).toHaveBeenCalledWith('adminUser');
  });

  it('handles malformed localStorage data gracefully', () => {
    localStorageMock.getItem.mockImplementation((key) => {
      if (key === 'adminToken') return 'valid-token';
      if (key === 'adminUser') return 'invalid-json';
      return null;
    });

    const { result } = renderHook(() => useAuthStore());
    
    // Should not throw error and should handle gracefully
    expect(result.current.token).toBe('valid-token');
    expect(result.current.admin).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('handles empty localStorage gracefully', () => {
    localStorageMock.getItem.mockReturnValue('');

    const { result } = renderHook(() => useAuthStore());
    
    expect(result.current.token).toBeNull();
    expect(result.current.admin).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('handles localStorage errors gracefully', () => {
    localStorageMock.getItem.mockImplementation(() => {
      throw new Error('LocalStorage error');
    });

    // Should not throw error during initialization
    expect(() => {
      renderHook(() => useAuthStore());
    }).not.toThrow();
  });

  it('maintains state consistency across multiple hook instances', () => {
    const { result: hook1 } = renderHook(() => useAuthStore());
    const { result: hook2 } = renderHook(() => useAuthStore());

    act(() => {
      hook1.current.token = 'shared-token';
      hook1.current.admin = { id: '1', username: 'admin', email: 'admin@test.com' };
      hook1.current.isAuthenticated = true;
    });

    expect(hook2.current.token).toBe('shared-token');
    expect(hook2.current.admin).toEqual({ id: '1', username: 'admin', email: 'admin@test.com' });
    expect(hook2.current.isAuthenticated).toBe(true);
  });
});
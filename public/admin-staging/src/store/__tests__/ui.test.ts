import { renderHook, act } from '@testing-library/react';
import { useUIStore } from '../ui';

describe('UI store', () => {
  beforeEach(() => {
    // Reset store state before each test
    useUIStore.getState().closeAllModals();
    useUIStore.getState().clearNotifications();
    useUIStore.getState().setSidebarOpen(true);
  });

  it('initializes with default state', () => {
    const { result } = renderHook(() => useUIStore());
    
    expect(result.current.activeTab).toBe('dashboard');
    expect(result.current.modals).toEqual({});
    expect(result.current.loading).toEqual({});
    expect(result.current.notifications).toEqual([]);
    expect(result.current.theme).toBe('light');
    expect(result.current.sidebarOpen).toBe(true);
  });

  describe('tab management', () => {
    it('sets active tab', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.setActiveTab('users');
      });

      expect(result.current.activeTab).toBe('users');
    });
  });

  describe('modal management', () => {
    it('opens and closes modal', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.openModal('createUser');
      });

      expect(result.current.modals).toEqual({ createUser: true });

      act(() => {
        result.current.closeModal('createUser');
      });

      expect(result.current.modals).toEqual({ createUser: false });
    });

    it('closes all modals', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.openModal('createUser');
        result.current.openModal('editUser');
      });

      expect(result.current.modals).toEqual({
        createUser: true,
        editUser: true,
      });

      act(() => {
        result.current.closeAllModals();
      });

      expect(result.current.modals).toEqual({});
    });
  });

  describe('loading state management', () => {
    it('sets and unsets loading state', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.setLoading('users', true);
      });

      expect(result.current.loading).toEqual({ users: true });

      act(() => {
        result.current.setLoading('users', false);
      });

      expect(result.current.loading).toEqual({ users: false });
    });

    it('manages multiple loading states', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.setLoading('users', true);
        result.current.setLoading('promoCodes', true);
      });

      expect(result.current.loading).toEqual({
        users: true,
        promoCodes: true,
      });

      act(() => {
        result.current.setLoading('users', false);
      });

      expect(result.current.loading).toEqual({
        users: false,
        promoCodes: true,
      });
    });
  });

  describe('notification management', () => {
    it('adds notification', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.addNotification({
          type: 'success',
          message: 'User created successfully',
        });
      });

      expect(result.current.notifications).toHaveLength(1);
      expect(result.current.notifications[0]).toMatchObject({
        type: 'success',
        message: 'User created successfully',
      });
      expect(result.current.notifications[0].id).toBeDefined();
    });

    it('removes notification', () => {
      const { result } = renderHook(() => useUIStore());

      let notificationId: string;

      act(() => {
        result.current.addNotification({
          type: 'success',
          message: 'User created successfully',
        });
      });

      expect(result.current.notifications).toHaveLength(1);
      notificationId = result.current.notifications[0].id;

      act(() => {
        result.current.removeNotification(notificationId);
      });

      expect(result.current.notifications).toHaveLength(0);
    });

    it('clears all notifications', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.addNotification({
          type: 'success',
          message: 'User created successfully',
        });
        result.current.addNotification({
          type: 'error',
          message: 'Failed to create user',
        });
      });

      expect(result.current.notifications).toHaveLength(2);

      act(() => {
        result.current.clearNotifications();
      });

      expect(result.current.notifications).toHaveLength(0);
    });

    it('auto-removes notification after duration', async () => {
      jest.useFakeTimers();
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.addNotification({
          type: 'success',
          message: 'User created successfully',
          duration: 1000,
        });
      });

      expect(result.current.notifications).toHaveLength(1);

      act(() => {
        jest.advanceTimersByTime(1000);
      });

      expect(result.current.notifications).toHaveLength(0);

      jest.useRealTimers();
    });
  });

  describe('theme management', () => {
    it('toggles theme', () => {
      const { result } = renderHook(() => useUIStore());

      expect(result.current.theme).toBe('light');

      act(() => {
        result.current.toggleTheme();
      });

      expect(result.current.theme).toBe('dark');

      act(() => {
        result.current.toggleTheme();
      });

      expect(result.current.theme).toBe('light');
    });
  });

  describe('sidebar management', () => {
    it('toggles sidebar', () => {
      const { result } = renderHook(() => useUIStore());

      expect(result.current.sidebarOpen).toBe(true);

      act(() => {
        result.current.toggleSidebar();
      });

      expect(result.current.sidebarOpen).toBe(false);

      act(() => {
        result.current.toggleSidebar();
      });

      expect(result.current.sidebarOpen).toBe(true);
    });

    it('sets sidebar state', () => {
      const { result } = renderHook(() => useUIStore());

      act(() => {
        result.current.setSidebarOpen(false);
      });

      expect(result.current.sidebarOpen).toBe(false);

      act(() => {
        result.current.setSidebarOpen(true);
      });

      expect(result.current.sidebarOpen).toBe(true);
    });
  });
});
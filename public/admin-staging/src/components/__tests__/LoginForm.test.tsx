import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { LoginForm } from '../auth/LoginForm';
import { useAuthStore } from '@/store/auth';
import { useUIStore } from '@/store/ui';

// Mock the stores
jest.mock('@/store/auth');
jest.mock('@/store/ui');

const mockUseAuthStore = useAuthStore as jest.MockedFunction<typeof useAuthStore>;
const mockUseUIStore = useUIStore as jest.MockedFunction<typeof useUIStore>;

describe('LoginForm component', () => {
  const mockLogin = jest.fn();
  const mockAddNotification = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    
    mockUseAuthStore.mockReturnValue({
      login: mockLogin,
      isLoading: false,
      admin: null,
      token: null,
      isAuthenticated: false,
      logout: jest.fn(),
      validateSession: jest.fn(),
      setLoading: jest.fn(),
    });

    mockUseUIStore.mockReturnValue({
      addNotification: mockAddNotification,
      activeTab: 'dashboard',
      setActiveTab: jest.fn(),
      modals: {},
      openModal: jest.fn(),
      closeModal: jest.fn(),
      closeAllModals: jest.fn(),
      loading: {},
      setLoading: jest.fn(),
      notifications: [],
      removeNotification: jest.fn(),
      clearNotifications: jest.fn(),
      theme: 'light',
      toggleTheme: jest.fn(),
      sidebarOpen: true,
      toggleSidebar: jest.fn(),
      setSidebarOpen: jest.fn(),
    });
  });

  it('renders login form', () => {
    render(<LoginForm />);
    
    expect(screen.getByText('Homework Helper Admin')).toBeInTheDocument();
    expect(screen.getByText('STAGING ENVIRONMENT')).toBeInTheDocument();
    expect(screen.getByText('Sign in to your account')).toBeInTheDocument();
    expect(screen.getByLabelText('Username')).toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in to staging/i })).toBeInTheDocument();
  });

  it('handles form submission with valid data', async () => {
    mockLogin.mockResolvedValue(undefined);
    
    render(<LoginForm />);
    
    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    
    fireEvent.change(usernameInput, { target: { value: 'admin' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('admin', 'password123');
      expect(mockAddNotification).toHaveBeenCalledWith({
        type: 'success',
        message: 'Login successful!',
      });
    });
  });

  it('shows loading state during login', async () => {
    mockUseAuthStore.mockReturnValue({
      login: mockLogin,
      isLoading: true,
      admin: null,
      token: null,
      isAuthenticated: false,
      logout: jest.fn(),
      validateSession: jest.fn(),
      setLoading: jest.fn(),
    });
    
    render(<LoginForm />);
    
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    expect(submitButton).toBeDisabled();
  });

  it('handles login error', async () => {
    const error = new Error('Invalid credentials');
    mockLogin.mockRejectedValue(error);
    
    render(<LoginForm />);
    
    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    
    fireEvent.change(usernameInput, { target: { value: 'admin' } });
    fireEvent.change(passwordInput, { target: { value: 'wrong-password' } });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('admin', 'wrong-password');
      expect(mockAddNotification).toHaveBeenCalledWith({
        type: 'error',
        message: 'Invalid credentials',
      });
    });
  });

  it('handles network error', async () => {
    const error = new Error('Network error');
    mockLogin.mockRejectedValue(error);
    
    render(<LoginForm />);
    
    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    
    fireEvent.change(usernameInput, { target: { value: 'admin' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockAddNotification).toHaveBeenCalledWith({
        type: 'error',
        message: 'Network error',
      });
    });
  });

  it('handles generic error', async () => {
    const error = new Error('Login failed. Please try again.');
    mockLogin.mockRejectedValue(error);
    
    render(<LoginForm />);
    
    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    
    fireEvent.change(usernameInput, { target: { value: 'admin' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockAddNotification).toHaveBeenCalledWith({
        type: 'error',
        message: 'Login failed. Please try again.',
      });
    });
  });

  it('shows password visibility toggle', () => {
    render(<LoginForm />);
    
    const passwordInput = screen.getByLabelText('Password');
    const toggleButton = screen.getByRole('button', { name: /show password/i });
    
    expect(passwordInput).toHaveAttribute('type', 'password');
    
    fireEvent.click(toggleButton);
    expect(passwordInput).toHaveAttribute('type', 'text');
    
    fireEvent.click(toggleButton);
    expect(passwordInput).toHaveAttribute('type', 'password');
  });

  it('validates required fields', async () => {
    render(<LoginForm />);
    
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockLogin).not.toHaveBeenCalled();
    });
  });

  it('shows error message for invalid username/password', async () => {
    const error = new Error('Invalid username or password');
    mockLogin.mockRejectedValue(error);
    
    render(<LoginForm />);
    
    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in to staging/i });
    
    fireEvent.change(usernameInput, { target: { value: 'admin' } });
    fireEvent.change(passwordInput, { target: { value: 'wrong-password' } });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockAddNotification).toHaveBeenCalledWith({
        type: 'error',
        message: 'Invalid username or password',
      });
    });
  });
});
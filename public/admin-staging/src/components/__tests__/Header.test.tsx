import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Header } from '../layout/Header';
import { useAuthStore } from '@/store/auth';

// Mock the auth store
jest.mock('@/store/auth');
const mockUseAuthStore = useAuthStore as jest.MockedFunction<typeof useAuthStore>;

describe('Header component', () => {
  const mockLogout = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    
    mockUseAuthStore.mockReturnValue({
      admin: { id: '1', username: 'admin', email: 'admin@test.com' },
      logout: mockLogout,
      isAuthenticated: true,
      token: 'jwt-token',
      login: jest.fn(),
      isLoading: false,
      validateSession: jest.fn(),
      setLoading: jest.fn(),
    });
  });

  it('renders header with title and staging banner', () => {
    render(<Header />);
    
    expect(screen.getByText('📚 Homework Helper Admin')).toBeInTheDocument();
    expect(screen.getByText('STAGING ENVIRONMENT')).toBeInTheDocument();
    expect(screen.getByText('Manage users and subscriptions')).toBeInTheDocument();
  });

  it('displays admin information when available', () => {
    render(<Header />);
    
    expect(screen.getByText('admin')).toBeInTheDocument();
    expect(screen.getByText('admin@test.com')).toBeInTheDocument();
  });

  it('handles logout when logout button is clicked', () => {
    render(<Header />);
    
    const logoutButton = screen.getByRole('button', { name: /logout/i });
    fireEvent.click(logoutButton);
    
    expect(mockLogout).toHaveBeenCalled();
  });

  it('renders logout button', () => {
    render(<Header />);
    
    const logoutButton = screen.getByRole('button', { name: /logout/i });
    expect(logoutButton).toBeInTheDocument();
    expect(logoutButton).toHaveClass('bg-danger-600');
  });

  it('handles case when admin is null', () => {
    mockUseAuthStore.mockReturnValue({
      admin: null,
      logout: mockLogout,
      isAuthenticated: false,
      token: null,
      login: jest.fn(),
      isLoading: false,
      validateSession: jest.fn(),
      setLoading: jest.fn(),
    });

    render(<Header />);
    
    expect(screen.getByText('📚 Homework Helper Admin')).toBeInTheDocument();
    expect(screen.queryByText('admin')).not.toBeInTheDocument();
    expect(screen.queryByText('admin@test.com')).not.toBeInTheDocument();
  });

  it('renders staging environment banner', () => {
    render(<Header />);
    
    const stagingBanner = screen.getByText('STAGING ENVIRONMENT');
    expect(stagingBanner).toBeInTheDocument();
    expect(stagingBanner.parentElement).toHaveClass('bg-warning-100', 'text-warning-800');
  });

  it('renders admin email and username in correct format', () => {
    render(<Header />);
    
    const adminInfo = screen.getByText('admin').parentElement;
    expect(adminInfo).toHaveClass('text-right');
    
    const adminEmail = screen.getByText('admin@test.com');
    expect(adminEmail).toHaveClass('text-xs', 'text-gray-500');
  });
});
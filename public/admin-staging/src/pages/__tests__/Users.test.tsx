import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { Users } from '../Users';
import { adminService } from '@/services/admin';

// Mock the admin service
jest.mock('@/services/admin');
const mockAdminService = adminService as jest.Mocked<typeof adminService>;

// Mock users data
const mockUsers = [
  {
    user_id: 'user-1',
    email: 'test1@example.com',
    username: 'testuser1',
    subscription_status: 'active' as const,
    subscription_start_date: '2024-01-01',
    subscription_end_date: '2024-02-01',
    days_remaining: 15,
    is_active: true,
    is_banned: false,
    promo_code_used: null,
    auth_provider: 'email' as const,
    total_logins: 25,
    logins_last_7_days: 5,
    unique_devices: 2,
    last_login: '2024-01-15',
    created_at: '2024-01-01',
    updated_at: '2024-01-15',
  },
  {
    user_id: 'user-2',
    email: 'test2@example.com',
    username: 'testuser2',
    subscription_status: 'trial' as const,
    subscription_start_date: '2024-01-10',
    subscription_end_date: '2024-01-17',
    days_remaining: 2,
    is_active: true,
    is_banned: false,
    promo_code_used: null,
    auth_provider: 'google' as const,
    total_logins: 8,
    logins_last_7_days: 3,
    unique_devices: 1,
    last_login: '2024-01-15',
    created_at: '2024-01-10',
    updated_at: '2024-01-15',
  },
];

const mockUsersData = {
  items: mockUsers,
  pagination: {
    page: 1,
    limit: 20,
    totalPages: 1,
    totalItems: 2,
    hasNext: false,
    hasPrev: false,
  },
};

describe('Users page', () => {
  let queryClient: QueryClient;

  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: {
          retry: false,
        },
      },
    });
  });

  it('renders users page title', () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('Users', { selector: 'h1' })).toBeInTheDocument();
    expect(screen.getByText('Manage user accounts and subscriptions')).toBeInTheDocument();
  });

  it('displays loading state initially', () => {
    mockAdminService.getUsers.mockImplementation(() => new Promise(() => {}));
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('Users', { selector: 'h1' })).toBeInTheDocument();
  });

  it('displays users when loaded', async () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('test1@example.com')).toBeInTheDocument();
      expect(screen.getByText('test2@example.com')).toBeInTheDocument();
      expect(screen.getByText('testuser1')).toBeInTheDocument();
      expect(screen.getByText('testuser2')).toBeInTheDocument();
    });
  });

  it('displays user status badges', async () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('active')).toBeInTheDocument();
      expect(screen.getByText('trial')).toBeInTheDocument();
    });
  });

  it('displays user stats', async () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('15 days')).toBeInTheDocument();
      expect(screen.getByText('2 days')).toBeInTheDocument();
    });
  });

  it('handles search input', async () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    const searchInput = screen.getByPlaceholderText('Search by email, username, or user ID...');
    fireEvent.change(searchInput, { target: { value: 'test1' } });
    
    await waitFor(() => {
      expect(mockAdminService.getUsers).toHaveBeenCalledWith({
        page: 1,
        limit: 20,
        search: 'test1',
        status: '',
      });
    });
  });

  it('handles status filter', async () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    const statusSelect = screen.getByDisplayValue('All Status');
    fireEvent.change(statusSelect, { target: { value: 'active' } });
    
    await waitFor(() => {
      expect(mockAdminService.getUsers).toHaveBeenCalledWith({
        page: 1,
        limit: 20,
        search: '',
        status: 'active',
      });
    });
  });

  it('displays error state when API fails', async () => {
    mockAdminService.getUsers.mockRejectedValue(new Error('API Error'));
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText(/Failed to load users/)).toBeInTheDocument();
      expect(screen.getByText('Try Again')).toBeInTheDocument();
    });
  });

  it('displays empty state when no users found', async () => {
    const emptyUsersData = {
      items: [],
      pagination: {
        page: 1,
        limit: 20,
        totalPages: 0,
        totalItems: 0,
        hasNext: false,
        hasPrev: false,
      },
    };
    
    mockAdminService.getUsers.mockResolvedValue(emptyUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('No users found')).toBeInTheDocument();
      expect(screen.getByText('Try adjusting your search or filter criteria')).toBeInTheDocument();
    });
  });

  it('renders create user button', () => {
    mockAdminService.getUsers.mockResolvedValue(mockUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('Create User')).toBeInTheDocument();
  });

  it('renders pagination when multiple pages', async () => {
    const paginatedUsersData = {
      ...mockUsersData,
      pagination: {
        page: 1,
        limit: 20,
        totalPages: 3,
        totalItems: 60,
        hasNext: true,
        hasPrev: false,
      },
    };
    
    mockAdminService.getUsers.mockResolvedValue(paginatedUsersData);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Users />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('Showing 1 to 20 of 60 results')).toBeInTheDocument();
      expect(screen.getByText('Next')).toBeInTheDocument();
    });
  });
});

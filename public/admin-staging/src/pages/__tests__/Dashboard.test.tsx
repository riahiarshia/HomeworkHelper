import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { Dashboard } from '../Dashboard';
import { adminService } from '@/services/admin';

// Mock the admin service
jest.mock('@/services/admin');
const mockAdminService = adminService as jest.Mocked<typeof adminService>;

// Mock dashboard stats data
const mockStats = {
  total_users: 150,
  active_subscriptions: 120,
  trial_users: 25,
  expired_subscriptions: 5,
};

describe('Dashboard page', () => {
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

  it('renders dashboard title', () => {
    mockAdminService.getDashboardStats.mockResolvedValue(mockStats);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Overview of your admin panel')).toBeInTheDocument();
  });

  it('displays loading state initially', () => {
    mockAdminService.getDashboardStats.mockImplementation(() => new Promise(() => {}));
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    // Check for loading indicators (skeleton components)
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
  });

  it('displays stats when loaded', async () => {
    mockAdminService.getDashboardStats.mockResolvedValue(mockStats);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('150')).toBeInTheDocument(); // total_users
      expect(screen.getByText('120')).toBeInTheDocument(); // active_subscriptions
      expect(screen.getByText('25')).toBeInTheDocument(); // trial_users
      expect(screen.getByText('5')).toBeInTheDocument(); // expired_subscriptions
    });
  });

  it('displays error state when API fails', async () => {
    mockAdminService.getDashboardStats.mockRejectedValue(new Error('API Error'));
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText(/Failed to load dashboard data/)).toBeInTheDocument();
      expect(screen.getByText('Refresh')).toBeInTheDocument();
    });
  });

  it('renders quick actions section', () => {
    mockAdminService.getDashboardStats.mockResolvedValue(mockStats);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('Quick Actions')).toBeInTheDocument();
    expect(screen.getByText('Create New User')).toBeInTheDocument();
    expect(screen.getByText('Generate Promo Code')).toBeInTheDocument();
  });

  it('renders system status section', () => {
    mockAdminService.getDashboardStats.mockResolvedValue(mockStats);
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('System Status')).toBeInTheDocument();
    expect(screen.getByText('API Status')).toBeInTheDocument();
    expect(screen.getByText('Database')).toBeInTheDocument();
    expect(screen.getByText('Environment')).toBeInTheDocument();
  });
});

import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { BrowserRouter } from 'react-router-dom';
import App from '../App';
import { useAuthStore } from '@/store/auth';

// Mock the auth store
jest.mock('@/store/auth');
const mockUseAuthStore = useAuthStore as jest.MockedFunction<typeof useAuthStore>;

// Mock the Dashboard component
jest.mock('../pages/Dashboard', () => ({
  Dashboard: () => <div>Dashboard Component</div>,
}));

// Mock the Users component
jest.mock('../pages/Users', () => ({
  Users: () => <div>Users Component</div>,
}));

// Mock the Devices component
jest.mock('../pages/Devices', () => ({
  Devices: () => <div>Devices Component</div>,
}));

// Mock the PromoCodes component
jest.mock('../pages/PromoCodes', () => ({
  PromoCodes: () => <div>PromoCodes Component</div>,
}));

// Mock the ApiUsage component
jest.mock('../pages/ApiUsage', () => ({
  ApiUsage: () => <div>ApiUsage Component</div>,
}));

// Mock the Ledger component
jest.mock('../pages/Ledger', () => ({
  Ledger: () => <div>Ledger Component</div>,
}));

// Mock the AuditLog component
jest.mock('../pages/AuditLog', () => ({
  AuditLog: () => <div>AuditLog Component</div>,
}));

// Mock the LoginForm component
jest.mock('../components/auth/LoginForm', () => ({
  LoginForm: () => <div>Login Form Component</div>,
}));

// Mock the Layout component
jest.mock('../components/layout/Layout', () => ({
  Layout: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="layout">{children}</div>
  ),
}));

describe('App component', () => {
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

  const renderApp = () => {
    return render(
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </QueryClientProvider>
    );
  };

  it('renders login form when not authenticated', () => {
    mockUseAuthStore.mockReturnValue({
      isAuthenticated: false,
      isLoading: false,
      validateSession: jest.fn(),
      admin: null,
      token: null,
      login: jest.fn(),
      logout: jest.fn(),
      setLoading: jest.fn(),
    });

    renderApp();

    expect(screen.getByText('Login Form Component')).toBeInTheDocument();
  });

  it('renders dashboard when authenticated', async () => {
    mockUseAuthStore.mockReturnValue({
      isAuthenticated: true,
      isLoading: false,
      validateSession: jest.fn(),
      admin: { id: '1', username: 'admin', email: 'admin@test.com' },
      token: 'jwt-token',
      login: jest.fn(),
      logout: jest.fn(),
      setLoading: jest.fn(),
    });

    renderApp();

    await waitFor(() => {
      expect(screen.getByTestId('layout')).toBeInTheDocument();
    });
  });

  it('shows loading state initially', () => {
    mockUseAuthStore.mockReturnValue({
      isAuthenticated: false,
      isLoading: true,
      validateSession: jest.fn(),
      admin: null,
      token: null,
      login: jest.fn(),
      logout: jest.fn(),
      setLoading: jest.fn(),
    });

    renderApp();

    expect(screen.getByText('Dashboard Component')).toBeInTheDocument();
  });

  it('validates session on mount', () => {
    const mockValidateSession = jest.fn();
    mockUseAuthStore.mockReturnValue({
      isAuthenticated: false,
      isLoading: false,
      validateSession: mockValidateSession,
      admin: null,
      token: null,
      login: jest.fn(),
      logout: jest.fn(),
      setLoading: jest.fn(),
    });

    renderApp();

    expect(mockValidateSession).toHaveBeenCalled();
  });
});
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { Navigation } from '../layout/Navigation';

// Mock useNavigate and useLocation
const mockNavigate = jest.fn();
const mockLocation = { pathname: '/admin' };

jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useNavigate: () => mockNavigate,
  useLocation: () => mockLocation,
}));

describe('Navigation component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders navigation items', () => {
    render(
      <BrowserRouter>
        <Navigation isOpen={true} />
      </BrowserRouter>
    );

    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Users')).toBeInTheDocument();
    expect(screen.getByText('Device Analytics')).toBeInTheDocument();
    expect(screen.getByText('Promo Codes')).toBeInTheDocument();
    expect(screen.getByText('API Usage')).toBeInTheDocument();
    expect(screen.getByText('Ledger')).toBeInTheDocument();
    expect(screen.getByText('Audit Log')).toBeInTheDocument();
  });

  it('handles navigation click', () => {
    render(
      <BrowserRouter>
        <Navigation isOpen={true} />
      </BrowserRouter>
    );

    const usersButton = screen.getByText('Users');
    fireEvent.click(usersButton);

    expect(mockNavigate).toHaveBeenCalledWith('/admin/users');
  });

  it('calls onClose when navigation item is clicked', () => {
    const mockOnClose = jest.fn();
    
    render(
      <BrowserRouter>
        <Navigation isOpen={true} onClose={mockOnClose} />
      </BrowserRouter>
    );

    const usersButton = screen.getByText('Users');
    fireEvent.click(usersButton);

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('shows active state for current route', () => {
    const mockLocation = { pathname: '/admin/users' };
    jest.mocked(require('react-router-dom').useLocation).mockReturnValue(mockLocation);

    render(
      <BrowserRouter>
        <Navigation isOpen={true} />
      </BrowserRouter>
    );

    const usersButton = screen.getByText('Users');
    expect(usersButton).toHaveClass('bg-primary-100', 'text-primary-700');
  });

  it('applies correct width when open', () => {
    render(
      <BrowserRouter>
        <Navigation isOpen={true} />
      </BrowserRouter>
    );

    const nav = screen.getByRole('navigation');
    expect(nav).toHaveClass('w-64');
  });

  it('applies correct width when closed', () => {
    render(
      <BrowserRouter>
        <Navigation isOpen={false} />
      </BrowserRouter>
    );

    const nav = screen.getByRole('navigation');
    expect(nav).toHaveClass('w-16');
  });
});
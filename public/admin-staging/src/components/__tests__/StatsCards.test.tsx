import React from 'react';
import { render, screen } from '@testing-library/react';
import { StatsCards } from '../dashboard/StatsCards';
import type { DashboardStats } from '@/types/api';

describe('StatsCards component', () => {
  const mockStats: DashboardStats = {
    total_users: 150,
    active_subscriptions: 120,
    trial_users: 25,
    expired_subscriptions: 5,
  };

  it('renders all stat cards', () => {
    render(<StatsCards stats={mockStats} isLoading={false} />);
    
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('Active Subscriptions')).toBeInTheDocument();
    expect(screen.getByText('Trial Users')).toBeInTheDocument();
    expect(screen.getByText('Expired')).toBeInTheDocument();
  });

  it('displays correct stat values', () => {
    render(<StatsCards stats={mockStats} isLoading={false} />);
    
    expect(screen.getByText('150')).toBeInTheDocument();
    expect(screen.getByText('120')).toBeInTheDocument();
    expect(screen.getByText('25')).toBeInTheDocument();
    expect(screen.getByText('5')).toBeInTheDocument();
  });

  it('formats numbers with commas', () => {
    const largeStats: DashboardStats = {
      total_users: 1234567,
      active_subscriptions: 987654,
      trial_users: 12345,
      expired_subscriptions: 6789,
    };

    render(<StatsCards stats={largeStats} isLoading={false} />);
    
    expect(screen.getByText('1,234,567')).toBeInTheDocument();
    expect(screen.getByText('987,654')).toBeInTheDocument();
    expect(screen.getByText('12,345')).toBeInTheDocument();
    expect(screen.getByText('6,789')).toBeInTheDocument();
  });

  it('shows loading state with skeleton components', () => {
    render(<StatsCards stats={null} isLoading={true} />);
    
    // Check for skeleton components (they should be present in the DOM)
    const cards = screen.getAllByRole('generic').filter(el => 
      el.className.includes('animate-pulse') || el.className.includes('bg-gray-200')
    );
    expect(cards.length).toBeGreaterThan(0);
  });

  it('handles null stats gracefully', () => {
    render(<StatsCards stats={null} isLoading={false} />);
    
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getAllByText('0')).toHaveLength(4); // Should show 0 for null values
  });

  it('handles undefined stats gracefully', () => {
    render(<StatsCards stats={undefined} isLoading={false} />);
    
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getAllByText('0')).toHaveLength(4); // Should show 0 for undefined values
  });

  it('applies correct styling classes', () => {
    render(<StatsCards stats={mockStats} isLoading={false} />);
    
    const totalUsersCard = screen.getByText('Total Users').closest('.bg-white.rounded-lg.border.border-gray-200.shadow-sm');
    expect(totalUsersCard).toBeInTheDocument();
    
    const activeSubscriptionsCard = screen.getByText('Active Subscriptions').closest('.bg-white.rounded-lg.border.border-gray-200.shadow-sm');
    expect(activeSubscriptionsCard).toBeInTheDocument();
  });

  it('renders icons for each stat', () => {
    render(<StatsCards stats={mockStats} isLoading={false} />);
    
    // Check for icon containers (they should have the icon classes)
    const iconContainers = screen.getAllByRole('generic').filter(el => 
      el.className.includes('p-3 rounded-full')
    );
    expect(iconContainers.length).toBe(4); // One for each stat
  });

  it('applies hover effects', () => {
    render(<StatsCards stats={mockStats} isLoading={false} />);
    
    const cards = screen.getAllByRole('generic').filter(el => 
      el.className.includes('hover:shadow-md')
    );
    expect(cards.length).toBe(4); // One for each stat card
  });

  it('renders in grid layout', () => {
    render(<StatsCards stats={mockStats} isLoading={false} />);
    
    const gridContainer = screen.getByText('Total Users').closest('.grid.grid-cols-1.md\\:grid-cols-2.lg\\:grid-cols-4.gap-6');
    expect(gridContainer).toBeInTheDocument();
  });

  it('displays zero values correctly', () => {
    const zeroStats: DashboardStats = {
      total_users: 0,
      active_subscriptions: 0,
      trial_users: 0,
      expired_subscriptions: 0,
    };

    render(<StatsCards stats={zeroStats} isLoading={false} />);
    
    expect(screen.getAllByText('0')).toHaveLength(4);
  });
});
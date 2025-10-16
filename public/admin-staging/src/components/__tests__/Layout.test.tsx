import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Layout } from '../layout/Layout';
import { useUIStore } from '@/store/ui';
import { BrowserRouter } from 'react-router-dom';

// Mock the UI store
jest.mock('@/store/ui');
const mockUseUIStore = useUIStore as jest.MockedFunction<typeof useUIStore>;

describe('Layout component', () => {
  const mockToggleSidebar = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    
    mockUseUIStore.mockReturnValue({
      sidebarOpen: true,
      toggleSidebar: mockToggleSidebar,
      setSidebarOpen: jest.fn(),
      activeTab: 'dashboard',
      setActiveTab: jest.fn(),
      modals: {},
      openModal: jest.fn(),
      closeModal: jest.fn(),
      closeAllModals: jest.fn(),
      loading: {},
      setLoading: jest.fn(),
      notifications: [],
      addNotification: jest.fn(),
      removeNotification: jest.fn(),
      clearNotifications: jest.fn(),
      theme: 'light',
      toggleTheme: jest.fn(),
    });
  });

  it('renders layout with children', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });

  it('renders header component', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    expect(screen.getByText('📚 Homework Helper Admin')).toBeInTheDocument();
  });

  it('renders navigation component', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Users')).toBeInTheDocument();
  });

  it('shows mobile menu button on small screens', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const menuButton = screen.getByRole('button', { name: '' }); // The mobile toggle button has no aria-label
    expect(menuButton).toBeInTheDocument();
    expect(menuButton.closest('div')).toHaveClass('lg:hidden');
  });

  it('handles sidebar toggle', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const menuButton = screen.getByRole('button', { name: '' }); // The mobile toggle button has no aria-label
    fireEvent.click(menuButton);
    
    expect(mockToggleSidebar).toHaveBeenCalled();
  });

  it('shows overlay when sidebar is open on mobile', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const overlay = document.querySelector('.fixed.inset-0.z-40.bg-black.bg-opacity-50.lg\\:hidden');
    expect(overlay).toBeInTheDocument();
  });

  it('handles overlay click to close sidebar', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const overlay = document.querySelector('.fixed.inset-0.z-40.bg-black.bg-opacity-50.lg\\:hidden');
    if (overlay) {
      fireEvent.click(overlay);
      expect(mockToggleSidebar).toHaveBeenCalled();
    }
  });

  it('applies correct classes when sidebar is open', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const sidebar = screen.getByText('Dashboard').closest('nav');
    expect(sidebar).toHaveClass('w-64'); // When open, sidebar has w-64 class
  });

  it('applies correct classes when sidebar is closed', () => {
    mockUseUIStore.mockReturnValue({
      sidebarOpen: false,
      toggleSidebar: mockToggleSidebar,
      setSidebarOpen: jest.fn(),
      activeTab: 'dashboard',
      setActiveTab: jest.fn(),
      modals: {},
      openModal: jest.fn(),
      closeModal: jest.fn(),
      closeAllModals: jest.fn(),
      loading: {},
      setLoading: jest.fn(),
      notifications: [],
      addNotification: jest.fn(),
      removeNotification: jest.fn(),
      clearNotifications: jest.fn(),
      theme: 'light',
      toggleTheme: jest.fn(),
    });

    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    // When closed, the navigation only shows icons (no text), so we need to find by icon
    const nav = document.querySelector('nav');
    expect(nav).toHaveClass('w-16'); // When closed, sidebar has w-16 class
  });

  it('renders main content area', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const mainContent = screen.getByText('Test Content').closest('.flex-1.lg\\:ml-0');
    expect(mainContent).toBeInTheDocument();
  });

  it('renders content with proper padding', () => {
    render(
      <BrowserRouter>
        <Layout>
          <div>Test Content</div>
        </Layout>
      </BrowserRouter>
    );
    
    const contentContainer = screen.getByText('Test Content').closest('.p-6');
    expect(contentContainer).toBeInTheDocument();
  });
});
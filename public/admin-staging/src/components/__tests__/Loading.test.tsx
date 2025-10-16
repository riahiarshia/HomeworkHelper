import React from 'react';
import { render, screen } from '@testing-library/react';
import { Loading, LoadingSpinner, LoadingOverlay, Skeleton } from '../ui/Loading';

describe('Loading components', () => {
  describe('Loading', () => {
    it('renders loading with default message', () => {
      render(<Loading />);
      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });

    it('renders loading with custom message', () => {
      render(<Loading message="Please wait" />);
      expect(screen.getByText('Please wait')).toBeInTheDocument();
    });

    it('applies correct styling', () => {
      render(<Loading />);
      const loading = screen.getByText('Loading...').closest('div');
      expect(loading).toHaveClass('flex', 'flex-col', 'items-center', 'justify-center', 'p-8');
    });

    it('applies custom className', () => {
      render(<Loading className="custom-loading" />);
      const loading = screen.getByText('Loading...').closest('div');
      expect(loading).toHaveClass('custom-loading');
    });

    it('renders with spinner', () => {
      render(<Loading />);
      const spinner = screen.getByRole('status');
      expect(spinner).toBeInTheDocument();
    });
  });

  describe('LoadingSpinner', () => {
    it('renders spinner', () => {
      render(<LoadingSpinner />);
      const spinner = screen.getByRole('status');
      expect(spinner).toBeInTheDocument();
    });

    it('applies correct styling', () => {
      render(<LoadingSpinner />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveClass('animate-spin', 'h-8', 'w-8', 'text-blue-600');
    });

    it('applies custom size', () => {
      render(<LoadingSpinner size="sm" />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveClass('h-4', 'w-4');
    });

    it('applies custom size large', () => {
      render(<LoadingSpinner size="lg" />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveClass('h-12', 'w-12');
    });

    it('applies custom size xl', () => {
      render(<LoadingSpinner size="xl" />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveClass('h-16', 'w-16');
    });

    it('applies custom className', () => {
      render(<LoadingSpinner className="custom-spinner" />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveClass('custom-spinner');
    });

    it('has correct aria-label', () => {
      render(<LoadingSpinner />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveAttribute('aria-label', 'Loading');
    });

    it('renders with custom aria-label', () => {
      render(<LoadingSpinner aria-label="Custom loading" />);
      const spinner = screen.getByRole('status');
      expect(spinner).toHaveAttribute('aria-label', 'Custom loading');
    });
  });

  describe('LoadingOverlay', () => {
    it('renders overlay with children', () => {
      render(
        <LoadingOverlay>
          <div>Content</div>
        </LoadingOverlay>
      );
      expect(screen.getByText('Content')).toBeInTheDocument();
    });

  it('renders loading when isLoading is true', () => {
    render(
      <LoadingOverlay isLoading={true}>
        <div>Content</div>
      </LoadingOverlay>
    );
    expect(screen.getByText('Please wait')).toBeInTheDocument();
  });

    it('does not render loading when isLoading is false', () => {
      render(
        <LoadingOverlay isLoading={false}>
          <div>Content</div>
        </LoadingOverlay>
      );
      expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
    });

    it('renders custom loading message', () => {
      render(
        <LoadingOverlay isLoading={true} message="Please wait">
          <div>Content</div>
        </LoadingOverlay>
      );
      expect(screen.getByText('Please wait')).toBeInTheDocument();
    });

  it('applies correct styling to overlay', () => {
    render(
      <LoadingOverlay isLoading={true}>
        <div>Content</div>
      </LoadingOverlay>
    );
    const overlay = screen.getByText('Please wait').closest('div')?.parentElement;
    expect(overlay).toHaveClass('absolute', 'inset-0', 'bg-white', 'bg-opacity-75', 'flex', 'items-center', 'justify-center', 'z-10');
  });

  it('applies custom className to overlay', () => {
    render(
      <LoadingOverlay isLoading={true} className="custom-overlay">
        <div>Content</div>
      </LoadingOverlay>
    );
    const container = screen.getByText('Content').closest('div')?.parentElement;
    expect(container).toHaveClass('custom-overlay');
  });

  it('renders with relative positioning container', () => {
    render(
      <LoadingOverlay isLoading={true}>
        <div>Content</div>
      </LoadingOverlay>
    );
    const container = screen.getByText('Content').closest('div')?.parentElement;
    expect(container).toHaveClass('relative');
  });
  });

  describe('Skeleton', () => {
    it('renders skeleton with default height', () => {
      render(<Skeleton />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toBeInTheDocument();
    });

    it('applies correct styling', () => {
      render(<Skeleton />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('animate-pulse', 'bg-gray-200', 'rounded', 'h-4');
    });

    it('applies custom height', () => {
      render(<Skeleton height="h-8" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('h-8');
    });

    it('applies custom width', () => {
      render(<Skeleton width="w-32" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('w-32');
    });

    it('applies custom className', () => {
      render(<Skeleton className="custom-skeleton" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('custom-skeleton');
    });

    it('has correct aria-label', () => {
      render(<Skeleton />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveAttribute('aria-label', 'Loading');
    });

    it('renders with custom aria-label', () => {
      render(<Skeleton aria-label="Custom skeleton" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveAttribute('aria-label', 'Custom skeleton');
    });

    it('renders with custom dimensions', () => {
      render(<Skeleton height="h-12" width="w-48" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('h-12', 'w-48');
    });

    it('renders with rounded corners', () => {
      render(<Skeleton />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded');
    });

    it('renders with pulse animation', () => {
      render(<Skeleton />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('animate-pulse');
    });

    it('renders with gray background', () => {
      render(<Skeleton />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('bg-gray-200');
    });

    it('renders with custom background color', () => {
      render(<Skeleton className="bg-gray-300" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('bg-gray-300');
    });

    it('renders with custom border radius', () => {
      render(<Skeleton className="rounded-lg" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-lg');
    });

    it('renders with custom border radius full', () => {
      render(<Skeleton className="rounded-full" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-full');
    });

    it('renders with custom border radius none', () => {
      render(<Skeleton className="rounded-none" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-none');
    });

    it('renders with custom border radius xl', () => {
      render(<Skeleton className="rounded-xl" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-xl');
    });

    it('renders with custom border radius 2xl', () => {
      render(<Skeleton className="rounded-2xl" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-2xl');
    });

    it('renders with custom border radius 3xl', () => {
      render(<Skeleton className="rounded-3xl" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-3xl');
    });

    it('renders with custom border radius 4xl', () => {
      render(<Skeleton className="rounded-4xl" />);
      const skeleton = screen.getByRole('status');
      expect(skeleton).toHaveClass('rounded-4xl');
    });
  });
});
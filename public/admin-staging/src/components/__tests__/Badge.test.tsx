import React from 'react';
import { render, screen } from '@testing-library/react';
import { Badge } from '../ui/Badge';

describe('Badge component', () => {
  it('renders badge with children', () => {
    render(<Badge>Test Badge</Badge>);
    expect(screen.getByText('Test Badge')).toBeInTheDocument();
  });

  it('applies default variant classes', () => {
    render(<Badge>Test Badge</Badge>);
    const badge = screen.getByText('Test Badge');
    expect(badge).toHaveClass('bg-gray-100', 'text-gray-800');
  });

  it('applies success variant classes', () => {
    render(<Badge variant="success">Success Badge</Badge>);
    const badge = screen.getByText('Success Badge');
    expect(badge).toHaveClass('bg-success-100', 'text-success-800');
  });

  it('applies warning variant classes', () => {
    render(<Badge variant="warning">Warning Badge</Badge>);
    const badge = screen.getByText('Warning Badge');
    expect(badge).toHaveClass('bg-warning-100', 'text-warning-800');
  });

  it('applies danger variant classes', () => {
    render(<Badge variant="danger">Danger Badge</Badge>);
    const badge = screen.getByText('Danger Badge');
    expect(badge).toHaveClass('bg-danger-100', 'text-danger-800');
  });

  it('applies info variant classes', () => {
    render(<Badge variant="info">Info Badge</Badge>);
    const badge = screen.getByText('Info Badge');
    expect(badge).toHaveClass('bg-blue-100', 'text-blue-800');
  });

  it('applies small size classes', () => {
    render(<Badge size="sm">Small Badge</Badge>);
    const badge = screen.getByText('Small Badge');
    expect(badge).toHaveClass('px-2', 'py-1', 'text-xs');
  });

  it('applies medium size classes', () => {
    render(<Badge size="md">Medium Badge</Badge>);
    const badge = screen.getByText('Medium Badge');
    expect(badge).toHaveClass('px-2.5', 'py-0.5', 'text-sm');
  });

  it('applies large size classes', () => {
    render(<Badge size="lg">Large Badge</Badge>);
    const badge = screen.getByText('Large Badge');
    expect(badge).toHaveClass('px-3', 'py-1', 'text-base');
  });

  it('applies custom className', () => {
    render(<Badge className="custom-badge">Custom Badge</Badge>);
    const badge = screen.getByText('Custom Badge');
    expect(badge).toHaveClass('custom-badge');
  });

  it('applies base classes to all variants', () => {
    const variants = ['default', 'success', 'warning', 'danger', 'info'] as const;
    
    variants.forEach(variant => {
      const { unmount } = render(<Badge variant={variant}>Test</Badge>);
      const badge = screen.getByText('Test');
      expect(badge).toHaveClass('inline-flex', 'items-center', 'font-medium', 'rounded-full');
      unmount();
    });
  });

  it('renders as span element', () => {
    render(<Badge>Test Badge</Badge>);
    const badge = screen.getByText('Test Badge');
    expect(badge.tagName).toBe('SPAN');
  });

  it('passes through additional props', () => {
    render(<Badge data-testid="test-badge">Test Badge</Badge>);
    const badge = screen.getByTestId('test-badge');
    expect(badge).toBeInTheDocument();
  });

  it('handles empty children', () => {
    render(<Badge></Badge>);
    const badges = screen.getAllByRole('generic');
    const badge = badges.find(el => el.className.includes('inline-flex'));
    expect(badge).toBeInTheDocument();
    expect(badge).toBeEmptyDOMElement();
  });

  it('handles complex children', () => {
    render(
      <Badge>
        <span>Icon</span>
        <span>Text</span>
      </Badge>
    );
    
    expect(screen.getByText('Icon')).toBeInTheDocument();
    expect(screen.getByText('Text')).toBeInTheDocument();
  });

  it('applies correct classes for all size and variant combinations', () => {
    const variants = ['default', 'success', 'warning', 'danger', 'info'] as const;
    const sizes = ['sm', 'md', 'lg'] as const;
    
    variants.forEach(variant => {
      sizes.forEach(size => {
        const { unmount } = render(<Badge variant={variant} size={size}>Test</Badge>);
        const badge = screen.getByText('Test');
        
        // Check base classes
        expect(badge).toHaveClass('inline-flex', 'items-center', 'font-medium', 'rounded-full');
        
        // Check variant classes
        if (variant === 'success') {
          expect(badge).toHaveClass('bg-success-100', 'text-success-800');
        } else if (variant === 'warning') {
          expect(badge).toHaveClass('bg-warning-100', 'text-warning-800');
        } else if (variant === 'danger') {
          expect(badge).toHaveClass('bg-danger-100', 'text-danger-800');
        } else if (variant === 'info') {
          expect(badge).toHaveClass('bg-blue-100', 'text-blue-800');
        } else {
          expect(badge).toHaveClass('bg-gray-100', 'text-gray-800');
        }
        
        // Check size classes
        if (size === 'sm') {
          expect(badge).toHaveClass('px-2', 'py-1', 'text-xs');
        } else if (size === 'md') {
          expect(badge).toHaveClass('px-2.5', 'py-0.5', 'text-sm');
        } else {
          expect(badge).toHaveClass('px-3', 'py-1', 'text-base');
        }
        
        unmount();
      });
    });
  });
});
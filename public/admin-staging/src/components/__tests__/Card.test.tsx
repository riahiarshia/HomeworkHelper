import React from 'react';
import { render, screen } from '@testing-library/react';
import { Card, CardHeader, CardContent, CardFooter } from '../ui/Card';

describe('Card components', () => {
  it('renders card with children', () => {
    render(<Card>Test Content</Card>);
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });

  it('applies correct styling to card', () => {
    render(<Card>Test Content</Card>);
    const card = screen.getByText('Test Content').closest('div');
    expect(card).toHaveClass('bg-white', 'rounded-lg', 'border', 'border-gray-200', 'shadow-sm');
  });

  it('applies custom className to card', () => {
    render(<Card className="custom-card">Test Content</Card>);
    const card = screen.getByText('Test Content').closest('div');
    expect(card).toHaveClass('custom-card');
  });

  it('renders card header with children', () => {
    render(
      <Card>
        <CardHeader>Header Content</CardHeader>
      </Card>
    );
    expect(screen.getByText('Header Content')).toBeInTheDocument();
  });

  it('applies correct styling to card header', () => {
    render(
      <Card>
        <CardHeader>Header Content</CardHeader>
      </Card>
    );
    const header = screen.getByText('Header Content');
    expect(header).toHaveClass('px-6', 'py-4', 'border-b', 'border-gray-200');
  });

  it('applies custom className to card header', () => {
    render(
      <Card>
        <CardHeader className="custom-header">Header Content</CardHeader>
      </Card>
    );
    const header = screen.getByText('Header Content');
    expect(header).toHaveClass('custom-header');
  });

  it('renders card content with children', () => {
    render(
      <Card>
        <CardContent>Content</CardContent>
      </Card>
    );
    expect(screen.getByText('Content')).toBeInTheDocument();
  });

  it('applies correct styling to card content', () => {
    render(
      <Card>
        <CardContent>Content</CardContent>
      </Card>
    );
    const content = screen.getByText('Content');
    expect(content).toHaveClass('px-6', 'py-4');
  });

  it('applies custom className to card content', () => {
    render(
      <Card>
        <CardContent className="custom-content">Content</CardContent>
      </Card>
    );
    const content = screen.getByText('Content');
    expect(content).toHaveClass('custom-content');
  });

  it('renders card footer with children', () => {
    render(
      <Card>
        <CardFooter>Footer Content</CardFooter>
      </Card>
    );
    expect(screen.getByText('Footer Content')).toBeInTheDocument();
  });

  it('applies correct styling to card footer', () => {
    render(
      <Card>
        <CardFooter>Footer Content</CardFooter>
      </Card>
    );
    const footer = screen.getByText('Footer Content');
    expect(footer).toHaveClass('px-6', 'py-4', 'border-t', 'border-gray-200');
  });

  it('applies custom className to card footer', () => {
    render(
      <Card>
        <CardFooter className="custom-footer">Footer Content</CardFooter>
      </Card>
    );
    const footer = screen.getByText('Footer Content');
    expect(footer).toHaveClass('custom-footer');
  });

  it('renders complete card structure', () => {
    render(
      <Card>
        <CardHeader>Header</CardHeader>
        <CardContent>Content</CardContent>
        <CardFooter>Footer</CardFooter>
      </Card>
    );

    expect(screen.getByText('Header')).toBeInTheDocument();
    expect(screen.getByText('Content')).toBeInTheDocument();
    expect(screen.getByText('Footer')).toBeInTheDocument();
  });

  it('renders card with only content', () => {
    render(
      <Card>
        <CardContent>Only Content</CardContent>
      </Card>
    );

    expect(screen.getByText('Only Content')).toBeInTheDocument();
  });

  it('renders card with header and content', () => {
    render(
      <Card>
        <CardHeader>Header</CardHeader>
        <CardContent>Content</CardContent>
      </Card>
    );

    expect(screen.getByText('Header')).toBeInTheDocument();
    expect(screen.getByText('Content')).toBeInTheDocument();
  });

  it('renders card with content and footer', () => {
    render(
      <Card>
        <CardContent>Content</CardContent>
        <CardFooter>Footer</CardFooter>
      </Card>
    );

    expect(screen.getByText('Content')).toBeInTheDocument();
    expect(screen.getByText('Footer')).toBeInTheDocument();
  });

  it('renders card with header and footer', () => {
    render(
      <Card>
        <CardHeader>Header</CardHeader>
        <CardFooter>Footer</CardFooter>
      </Card>
    );

    expect(screen.getByText('Header')).toBeInTheDocument();
    expect(screen.getByText('Footer')).toBeInTheDocument();
  });

  it('handles complex children in card content', () => {
    render(
      <Card>
        <CardContent>
          <div>
            <h3>Title</h3>
            <p>Description</p>
            <button>Action</button>
          </div>
        </CardContent>
      </Card>
    );

    expect(screen.getByText('Title')).toBeInTheDocument();
    expect(screen.getByText('Description')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Action' })).toBeInTheDocument();
  });

  it('passes through additional props to card', () => {
    render(<Card data-testid="test-card">Test Content</Card>);
    const card = screen.getByTestId('test-card');
    expect(card).toBeInTheDocument();
  });

  it('passes through additional props to card header', () => {
    render(
      <Card>
        <CardHeader data-testid="test-header">Header Content</CardHeader>
      </Card>
    );
    const header = screen.getByTestId('test-header');
    expect(header).toBeInTheDocument();
  });

  it('passes through additional props to card content', () => {
    render(
      <Card>
        <CardContent data-testid="test-content">Content</CardContent>
      </Card>
    );
    const content = screen.getByTestId('test-content');
    expect(content).toBeInTheDocument();
  });

  it('passes through additional props to card footer', () => {
    render(
      <Card>
        <CardFooter data-testid="test-footer">Footer Content</CardFooter>
      </Card>
    );
    const footer = screen.getByTestId('test-footer');
    expect(footer).toBeInTheDocument();
  });

  it('renders with correct HTML structure', () => {
    render(
      <Card>
        <CardHeader>Header</CardHeader>
        <CardContent>Content</CardContent>
        <CardFooter>Footer</CardFooter>
      </Card>
    );

    const card = screen.getByText('Header').closest('div');
    expect(card).toBeInTheDocument();
    
    const header = screen.getByText('Header');
    expect(header).toBeInTheDocument();
    
    const content = screen.getByText('Content');
    expect(content).toBeInTheDocument();
    
    const footer = screen.getByText('Footer');
    expect(footer).toBeInTheDocument();
  });
});
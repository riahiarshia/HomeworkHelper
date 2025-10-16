import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Select } from '../ui/Select';

const mockOptions = [
  { value: 'option1', label: 'Option 1' },
  { value: 'option2', label: 'Option 2' },
  { value: 'option3', label: 'Option 3' },
];

describe('Select component', () => {
  it('renders select element', () => {
    render(<Select options={mockOptions} />);
    expect(screen.getByRole('combobox')).toBeInTheDocument();
  });

  it('renders all options', () => {
    render(<Select options={mockOptions} />);
    
    expect(screen.getByText('Option 1')).toBeInTheDocument();
    expect(screen.getByText('Option 2')).toBeInTheDocument();
    expect(screen.getByText('Option 3')).toBeInTheDocument();
  });

  it('renders with label', () => {
    render(<Select label="Test Label" options={mockOptions} />);
    expect(screen.getByLabelText('Test Label')).toBeInTheDocument();
  });

  it('renders with placeholder', () => {
    render(<Select placeholder="Select an option" options={mockOptions} />);
    expect(screen.getByText('Select an option')).toBeInTheDocument();
  });

  it('shows error message', () => {
    render(<Select error="This field is required" options={mockOptions} />);
    expect(screen.getByText('This field is required')).toBeInTheDocument();
  });

  it('shows helper text', () => {
    render(<Select helperText="This is helpful" options={mockOptions} />);
    expect(screen.getByText('This is helpful')).toBeInTheDocument();
  });

  it('handles value changes', () => {
    const handleChange = jest.fn();
    render(<Select options={mockOptions} onChange={handleChange} />);
    
    const select = screen.getByRole('combobox');
    fireEvent.change(select, { target: { value: 'option2' } });
    
    expect(handleChange).toHaveBeenCalled();
  });

  it('can be disabled', () => {
    render(<Select disabled options={mockOptions} />);
    const select = screen.getByRole('combobox');
    expect(select).toBeDisabled();
  });

  it('applies custom className', () => {
    render(<Select className="custom-class" options={mockOptions} />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveClass('custom-class');
  });

  it('applies error styling when error is present', () => {
    render(<Select error="Error message" options={mockOptions} />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveClass('border-danger-300', 'focus:ring-danger-500', 'focus:border-danger-500');
  });

  it('applies default styling when no error', () => {
    render(<Select options={mockOptions} />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveClass('border-gray-300', 'focus:ring-primary-500', 'focus:border-primary-500');
  });

  it('renders with correct default value', () => {
    render(<Select options={mockOptions} defaultValue="option2" />);
    const select = screen.getByRole('combobox') as HTMLSelectElement;
    expect(select.value).toBe('option2');
  });

  it('renders with correct controlled value', () => {
    render(<Select options={mockOptions} value="option3" />);
    const select = screen.getByRole('combobox') as HTMLSelectElement;
    expect(select.value).toBe('option3');
  });

  it('renders with required attribute', () => {
    render(<Select options={mockOptions} required />);
    const select = screen.getByRole('combobox');
    expect(select).toBeRequired();
  });

  it('renders with name attribute', () => {
    render(<Select options={mockOptions} name="test-select" />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveAttribute('name', 'test-select');
  });

  it('renders with id attribute', () => {
    render(<Select options={mockOptions} id="test-select" />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveAttribute('id', 'test-select');
  });

  it('generates unique id when not provided', () => {
    render(<Select options={mockOptions} />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveAttribute('id');
    expect(select.getAttribute('id')).toMatch(/^select-/);
  });

  it('associates label with select element', () => {
    render(<Select label="Test Label" options={mockOptions} />);
    const select = screen.getByRole('combobox');
    const label = screen.getByText('Test Label');
    
    expect(select).toHaveAttribute('id');
    expect(label).toHaveAttribute('for', select.getAttribute('id'));
  });

  it('renders with multiple selection', () => {
    render(<Select options={mockOptions} multiple />);
    const select = screen.getByRole('listbox');
    expect(select).toHaveAttribute('multiple');
  });

  it('renders with size attribute', () => {
    render(<Select options={mockOptions} size={3} />);
    const select = screen.getByRole('listbox');
    expect(select).toHaveAttribute('size', '3');
  });

  it('handles empty options array', () => {
    render(<Select options={[]} />);
    const select = screen.getByRole('combobox');
    expect(select).toBeInTheDocument();
    expect(select.children).toHaveLength(0);
  });

  it('handles options with empty values', () => {
    const optionsWithEmpty = [
      { value: '', label: 'Select...' },
      { value: 'option1', label: 'Option 1' },
    ];
    
    render(<Select options={optionsWithEmpty} />);
    
    expect(screen.getByText('Select...')).toBeInTheDocument();
    expect(screen.getByText('Option 1')).toBeInTheDocument();
  });

  it('renders with correct focus styles', () => {
    render(<Select options={mockOptions} />);
    const select = screen.getByRole('combobox');
    expect(select).toHaveClass('focus:outline-none', 'focus:ring-2', 'focus:ring-primary-500', 'focus:border-primary-500');
  });

  it('renders with correct disabled styles', () => {
    render(<Select options={mockOptions} disabled />);
    const select = screen.getByRole('combobox');
    expect(select).toBeDisabled();
    expect(select).toHaveClass('block', 'w-full', 'px-3', 'py-2', 'border', 'border-gray-300', 'rounded-md', 'shadow-sm');
  });
});
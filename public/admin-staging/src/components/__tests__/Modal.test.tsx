import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Modal } from '../ui/Modal';

describe('Modal component', () => {
  it('renders modal when isOpen is true', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    expect(screen.getByText('Modal Content')).toBeInTheDocument();
  });

  it('does not render modal when isOpen is false', () => {
    render(
      <Modal isOpen={false} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    expect(screen.queryByText('Modal Content')).not.toBeInTheDocument();
  });

  it('renders modal with title', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );
    expect(screen.getByText('Test Modal')).toBeInTheDocument();
  });

  it('renders modal with description in content', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Test Description</div>
      </Modal>
    );
    expect(screen.getByText('Test Description')).toBeInTheDocument();
  });

  it('renders modal with both title and description', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Test Description</div>
      </Modal>
    );
    expect(screen.getByText('Test Modal')).toBeInTheDocument();
    expect(screen.getByText('Test Description')).toBeInTheDocument();
  });

  it('calls onClose when close button is clicked', () => {
    const onClose = jest.fn();
    render(
      <Modal isOpen={true} onClose={onClose} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );
    
    const closeButton = screen.getByRole('button', { name: /close/i });
    fireEvent.click(closeButton);
    
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('calls onClose when backdrop is clicked', () => {
    const onClose = jest.fn();
    render(
      <Modal isOpen={true} onClose={onClose}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const backdrop = screen.getByRole('dialog').parentElement?.querySelector('.absolute.inset-0');
    fireEvent.click(backdrop!);
    
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('does not call onClose when modal content is clicked', () => {
    const onClose = jest.fn();
    render(
      <Modal isOpen={true} onClose={onClose}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const modalContent = screen.getByText('Modal Content');
    fireEvent.click(modalContent);
    
    expect(onClose).not.toHaveBeenCalled();
  });

  it('calls onClose when escape key is pressed', () => {
    const onClose = jest.fn();
    render(
      <Modal isOpen={true} onClose={onClose}>
        <div>Modal Content</div>
      </Modal>
    );
    
    fireEvent.keyDown(document, { key: 'Escape' });
    
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('does not call onClose when other keys are pressed', () => {
    const onClose = jest.fn();
    render(
      <Modal isOpen={true} onClose={onClose}>
        <div>Modal Content</div>
      </Modal>
    );
    
    fireEvent.keyDown(document, { key: 'Enter' });
    fireEvent.keyDown(document, { key: 'Tab' });
    fireEvent.keyDown(document, { key: 'Space' });
    
    expect(onClose).not.toHaveBeenCalled();
  });

  it('renders modal with correct ARIA attributes', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );
    
    const modal = screen.getByRole('dialog');
    expect(modal).toHaveAttribute('aria-modal', 'true');
    expect(modal).toHaveAttribute('aria-labelledby');
    expect(modal).toHaveAttribute('aria-describedby');
  });

  it('renders modal with custom size', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} size="lg">
        <div>Modal Content</div>
      </Modal>
    );
    
    const modal = screen.getByRole('dialog');
    expect(modal).toHaveClass('max-w-2xl');
  });

  it('renders modal with extra large size', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} size="xl">
        <div>Modal Content</div>
      </Modal>
    );
    
    const modal = screen.getByRole('dialog');
    expect(modal).toHaveClass('max-w-4xl');
  });

  it('renders modal with default size', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const modal = screen.getByRole('dialog');
    expect(modal).toHaveClass('max-w-lg');
  });

  it('renders modal with custom className', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} className="custom-modal">
        <div>Modal Content</div>
      </Modal>
    );
    
    const modal = screen.getByRole('dialog');
    expect(modal).toHaveClass('custom-modal');
  });

  it('renders modal with close button', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );
    
    const closeButton = screen.getByRole('button', { name: /close/i });
    expect(closeButton).toBeInTheDocument();
  });

  it('renders modal with close button icon', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );
    
    const closeButton = screen.getByRole('button', { name: /close/i });
    expect(closeButton).toHaveClass('text-gray-400', 'hover:text-gray-600');
  });

  it('renders modal with backdrop', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const backdrop = screen.getByRole('dialog').parentElement;
    expect(backdrop).toHaveClass('fixed', 'inset-0', 'z-50', 'flex', 'items-center', 'justify-center');
  });

  it('renders modal with correct z-index', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const backdrop = screen.getByRole('dialog').parentElement;
    expect(backdrop).toHaveClass('z-50');
  });

  it('renders modal with correct positioning', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const backdrop = screen.getByRole('dialog').parentElement;
    expect(backdrop).toHaveClass('fixed', 'inset-0', 'flex', 'items-center', 'justify-center');
  });

  it('renders modal with correct background', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const backdrop = screen.getByRole('dialog').parentElement;
    expect(backdrop).toHaveClass('fixed', 'inset-0', 'z-50', 'flex', 'items-center', 'justify-center');
  });

  it('renders modal with correct modal styling', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const modal = screen.getByRole('dialog');
    expect(modal).toHaveClass('relative', 'bg-white', 'rounded-lg', 'shadow-xl', 'w-full', 'mx-4', 'max-h-[90vh]', 'overflow-hidden', 'max-w-lg');
  });

  it('renders modal with correct header styling', () => {
    render(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );
    
    const header = screen.getByText('Test Modal').closest('div');
    expect(header).toHaveClass('flex', 'items-center', 'justify-between', 'p-6', 'border-b', 'border-gray-200');
  });

  it('renders modal with correct body styling', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
      </Modal>
    );
    
    const body = screen.getByText('Modal Content').closest('div[id="modal-description"]');
    expect(body).toHaveClass('p-6', 'overflow-y-auto', 'max-h-[calc(90vh-120px)]');
  });

  it('renders modal with correct footer styling', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
        <div>Footer</div>
      </Modal>
    );
    
    const footer = screen.getByText('Footer').closest('div[id="modal-description"]');
    expect(footer).toHaveClass('p-6', 'overflow-y-auto', 'max-h-[calc(90vh-120px)]');
  });

  it('renders modal with footer content', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>Modal Content</div>
        <div>Footer Content</div>
      </Modal>
    );
    
    expect(screen.getByText('Footer Content')).toBeInTheDocument();
  });

  it('renders modal with complex children', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>
          <h2>Title</h2>
          <p>Description</p>
          <button>Action</button>
        </div>
      </Modal>
    );
    
    expect(screen.getByText('Title')).toBeInTheDocument();
    expect(screen.getByText('Description')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Action' })).toBeInTheDocument();
  });

  it('renders modal with form elements', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <form>
          <input type="text" placeholder="Enter text" />
          <button type="submit">Submit</button>
        </form>
      </Modal>
    );
    
    expect(screen.getByPlaceholderText('Enter text')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();
  });

  it('renders modal with multiple buttons', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <div>
          <button>Cancel</button>
          <button>Save</button>
          <button>Delete</button>
        </div>
      </Modal>
    );
    
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Delete' })).toBeInTheDocument();
  });

  it('renders modal with list items', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <ul>
          <li>Item 1</li>
          <li>Item 2</li>
          <li>Item 3</li>
        </ul>
      </Modal>
    );
    
    expect(screen.getByText('Item 1')).toBeInTheDocument();
    expect(screen.getByText('Item 2')).toBeInTheDocument();
    expect(screen.getByText('Item 3')).toBeInTheDocument();
  });

  it('renders modal with table', () => {
    render(
      <Modal isOpen={true} onClose={() => {}}>
        <table>
          <thead>
            <tr>
              <th>Header 1</th>
              <th>Header 2</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Cell 1</td>
              <td>Cell 2</td>
            </tr>
          </tbody>
        </table>
      </Modal>
    );
    
    expect(screen.getByText('Header 1')).toBeInTheDocument();
    expect(screen.getByText('Header 2')).toBeInTheDocument();
    expect(screen.getByText('Cell 1')).toBeInTheDocument();
    expect(screen.getByText('Cell 2')).toBeInTheDocument();
  });
});
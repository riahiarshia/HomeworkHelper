import * as React from 'react';
import { Loader2 } from 'lucide-react';
import { cn } from '@/utils/cn';

interface LoadingProps {
  message?: string;
  className?: string;
}

const Loading: React.FC<LoadingProps> = ({ message = 'Loading...', className }) => {
  return (
    <div className={cn('flex flex-col items-center justify-center p-8', className)}>
      <LoadingSpinner size="lg" />
      <p className="mt-2 text-sm text-gray-600">{message}</p>
    </div>
  );
};

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
  'aria-label'?: string;
}

const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({ 
  size = 'md', 
  className, 
  'aria-label': ariaLabel = 'Loading' 
}) => {
  const sizes = {
    sm: 'h-4 w-4',
    md: 'h-8 w-8',
    lg: 'h-12 w-12',
    xl: 'h-16 w-16',
  };

  return (
    <Loader2 
      className={cn('animate-spin text-blue-600', sizes[size], className)}
      role="status"
      aria-label={ariaLabel}
    />
  );
};

interface LoadingOverlayProps {
  isLoading: boolean;
  children: React.ReactNode;
  className?: string;
  message?: string;
}

const LoadingOverlay: React.FC<LoadingOverlayProps> = ({ 
  isLoading, 
  children, 
  className, 
  message = 'Please wait' 
}) => (
  <div className={cn('relative', className)}>
    {children}
    {isLoading && (
      <div className="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-10">
        <Loading message={message} />
      </div>
    )}
  </div>
);

interface SkeletonProps {
  className?: string;
  height?: string;
  width?: string;
  'aria-label'?: string;
}

const Skeleton: React.FC<SkeletonProps> = ({ 
  className, 
  height = 'h-4', 
  width,
  'aria-label': ariaLabel = 'Loading' 
}) => {
  return (
    <div 
      className={cn('animate-pulse bg-gray-200 rounded', height, width, className)}
      role="status"
      aria-label={ariaLabel}
    />
  );
};

export { Loading, LoadingSpinner, LoadingOverlay, Skeleton };

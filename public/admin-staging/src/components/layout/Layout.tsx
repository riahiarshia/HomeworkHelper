import React from 'react';
import { Menu, X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Header } from './Header';
import { Navigation } from './Navigation';
import { useUIStore } from '@/store/ui';
import { cn } from '@/utils/cn';

interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const { sidebarOpen, toggleSidebar } = useUIStore();

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      
      <div className="flex">
        {/* Mobile sidebar overlay */}
        {sidebarOpen && (
          <div
            className="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
            onClick={() => toggleSidebar()}
          />
        )}
        
        {/* Sidebar */}
        <div className={cn(
          'fixed inset-y-0 left-0 z-50 lg:static lg:inset-0 transition-transform duration-300',
          sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        )}>
          <Navigation isOpen={sidebarOpen} onClose={() => toggleSidebar()} />
        </div>
        
        {/* Main content */}
        <div className="flex-1 lg:ml-0">
          <div className="p-6">
            {children}
          </div>
        </div>
      </div>
      
      {/* Mobile menu button */}
      <div className="fixed top-4 left-4 z-50 lg:hidden">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => toggleSidebar()}
          className="p-2"
        >
          {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </Button>
      </div>
    </div>
  );
};

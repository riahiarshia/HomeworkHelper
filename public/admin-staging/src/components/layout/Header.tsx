import React from 'react';
import { LogOut, AlertTriangle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { useAuthStore } from '@/store/auth';

export const Header: React.FC = () => {
  const { admin, logout } = useAuthStore();

  const handleLogout = async () => {
    await logout();
  };

  return (
    <header className="bg-white border-b border-gray-200 px-6 py-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          {/* Staging Banner */}
          <div className="flex items-center space-x-2 bg-warning-100 text-warning-800 px-3 py-1 rounded-md">
            <AlertTriangle className="h-4 w-4" />
            <span className="text-sm font-medium">STAGING ENVIRONMENT</span>
          </div>
          
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              📚 Homework Helper Admin
            </h1>
            <p className="text-sm text-gray-600">Manage users and subscriptions</p>
          </div>
        </div>

        <div className="flex items-center space-x-4">
          {admin && (
            <div className="text-right">
              <p className="text-sm font-medium text-gray-900">{admin.username}</p>
              <p className="text-xs text-gray-500">{admin.email}</p>
            </div>
          )}
          
          <Button
            variant="danger"
            size="sm"
            onClick={handleLogout}
            className="flex items-center space-x-2"
          >
            <LogOut className="h-4 w-4" />
            <span>Logout</span>
          </Button>
        </div>
      </div>
    </header>
  );
};

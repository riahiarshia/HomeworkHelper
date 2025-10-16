import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { cn } from '@/utils/cn';
import {
  BarChart3,
  Users,
  Smartphone,
  Tag,
  Activity,
  Shield,
  FileText,
} from 'lucide-react';

const navigationItems = [
  { id: 'dashboard', label: 'Dashboard', icon: BarChart3, path: '/admin' },
  { id: 'users', label: 'Users', icon: Users, path: '/admin/users' },
  { id: 'devices', label: 'Device Analytics', icon: Smartphone, path: '/admin/devices' },
  { id: 'promoCodes', label: 'Promo Codes', icon: Tag, path: '/admin/promo-codes' },
  { id: 'apiUsage', label: 'API Usage', icon: Activity, path: '/admin/api-usage' },
  { id: 'ledger', label: 'Ledger', icon: Shield, path: '/admin/ledger' },
  { id: 'auditLog', label: 'Audit Log', icon: FileText, path: '/admin/audit-log' },
];

interface NavigationProps {
  isOpen: boolean;
  onClose?: () => void;
}

export const Navigation: React.FC<NavigationProps> = ({ isOpen, onClose }) => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleNavigation = (path: string) => {
    navigate(path);
    onClose?.();
  };

  return (
    <nav className={cn(
      'bg-white border-r border-gray-200 h-full transition-all duration-300',
      isOpen ? 'w-64' : 'w-16'
    )}>
      <div className="p-4">
        <div className="space-y-2">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            
            return (
              <button
                key={item.id}
                onClick={() => handleNavigation(item.path)}
                className={cn(
                  'w-full flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors',
                  isActive
                    ? 'bg-primary-100 text-primary-700'
                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                )}
              >
                <Icon className={cn('h-5 w-5', isOpen ? 'mr-3' : 'mx-auto')} />
                {isOpen && <span>{item.label}</span>}
              </button>
            );
          })}
        </div>
      </div>
    </nav>
  );
};

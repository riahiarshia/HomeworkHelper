import * as React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Layout } from '@/components/layout/Layout';
import { LoginForm } from '@/components/auth/LoginForm';
import { useAuthStore } from '@/store/auth';
import { LoadingSpinner } from '@/components/ui/Loading';

// Lazy load pages for better performance
const Dashboard = React.lazy(() => import('@/pages/Dashboard').then(module => ({ default: module.Dashboard })));
const Users = React.lazy(() => import('@/pages/Users').then(module => ({ default: module.Users })));
const Devices = React.lazy(() => import('@/pages/Devices').then(module => ({ default: module.Devices })));
const PromoCodes = React.lazy(() => import('@/pages/PromoCodes').then(module => ({ default: module.PromoCodes })));
const ApiUsage = React.lazy(() => import('@/pages/ApiUsage').then(module => ({ default: module.ApiUsage })));
const Ledger = React.lazy(() => import('@/pages/Ledger').then(module => ({ default: module.Ledger })));
const AuditLog = React.lazy(() => import('@/pages/AuditLog').then(module => ({ default: module.AuditLog })));

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, isLoading, validateSession } = useAuthStore();

  React.useEffect(() => {
    if (!isAuthenticated && !isLoading) {
      validateSession();
    }
  }, [isAuthenticated, isLoading, validateSession]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/admin/login" replace />;
  }

  return <Layout>{children}</Layout>;
};

const App: React.FC = () => {
  const { isAuthenticated, isLoading, validateSession } = useAuthStore();

  React.useEffect(() => {
    validateSession();
  }, [validateSession]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <Routes>
      <Route
        path="/admin/login"
        element={
          isAuthenticated ? (
            <Navigate to="/admin" replace />
          ) : (
            <LoginForm />
          )
        }
      />
      
      <Route
        path="/admin"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <Dashboard />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/admin/users"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <Users />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/admin/devices"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <Devices />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/admin/promo-codes"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <PromoCodes />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/admin/api-usage"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <ApiUsage />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/admin/ledger"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <Ledger />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route
        path="/admin/audit-log"
        element={
          <ProtectedRoute>
            <React.Suspense fallback={<LoadingSpinner size="lg" />}>
              <AuditLog />
            </React.Suspense>
          </ProtectedRoute>
        }
      />
      
      <Route path="*" element={<Navigate to="/admin" replace />} />
    </Routes>
  );
};

export default App;

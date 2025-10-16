import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { AlertTriangle, Eye, EyeOff } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';
import { useAuthStore } from '@/store/auth';
import { useUIStore } from '@/store/ui';

interface LoginFormData {
  username: string;
  password: string;
}

export const LoginForm: React.FC = () => {
  const [showPassword, setShowPassword] = useState(false);
  const { login, isLoading } = useAuthStore();
  const { addNotification } = useUIStore();

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError,
  } = useForm<LoginFormData>();

  const onSubmit = async (data: LoginFormData) => {
    try {
      await login(data.username, data.password);
      addNotification({
        type: 'success',
        message: 'Login successful!',
      });
    } catch (error: any) {
      const errorMessage = error?.message || 'Login failed. Please try again.';
      
      if (errorMessage.includes('username') || errorMessage.includes('password')) {
        setError('root', { message: 'Invalid username or password' });
      } else {
        setError('root', { message: errorMessage });
      }
      
      addNotification({
        type: 'error',
        message: errorMessage,
      });
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <h2 className="text-3xl font-bold text-gray-900">
            Homework Helper Admin
          </h2>
          <div className="mt-4 flex items-center justify-center space-x-2 bg-warning-100 text-warning-800 px-4 py-2 rounded-md">
            <AlertTriangle className="h-5 w-5" />
            <span className="text-sm font-medium">STAGING ENVIRONMENT</span>
          </div>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <Card>
          <CardHeader>
            <h3 className="text-lg font-medium text-gray-900 text-center">
              Sign in to your account
            </h3>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
              {errors.root && (
                <div className="bg-danger-50 border border-danger-200 rounded-md p-4">
                  <div className="flex">
                    <div className="ml-3">
                      <p className="text-sm text-danger-700">{errors.root.message}</p>
                    </div>
                  </div>
                </div>
              )}

              <Input
                label="Username"
                type="text"
                autoComplete="username"
                error={errors.username?.message}
                {...register('username', {
                  required: 'Username is required',
                })}
              />

              <div className="relative">
                <Input
                  label="Password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  error={errors.password?.message}
                  {...register('password', {
                    required: 'Password is required',
                  })}
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? (
                    <EyeOff className="h-5 w-5 text-gray-400" />
                  ) : (
                    <Eye className="h-5 w-5 text-gray-400" />
                  )}
                </button>
              </div>

              <Button
                type="submit"
                className="w-full"
                loading={isLoading}
                disabled={isLoading}
              >
                Sign in to STAGING
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

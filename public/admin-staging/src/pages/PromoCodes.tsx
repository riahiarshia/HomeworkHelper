import React from 'react';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';

export const PromoCodes: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Promo Code Management</h1>
        <p className="text-gray-600">Create and manage promotional codes</p>
      </div>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Active Promo Codes</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Promo code management will be implemented here</p>
            <p className="text-sm mt-2">This will show active codes, usage stats, and creation tools</p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Create New Promo Code</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Promo code creation form will be implemented here</p>
            <p className="text-sm mt-2">This will allow creating codes with specific durations and usage limits</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

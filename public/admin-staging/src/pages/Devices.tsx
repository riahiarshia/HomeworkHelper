import React from 'react';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';

export const Devices: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Device Analytics</h1>
        <p className="text-gray-600">Monitor device usage and detect potential fraud</p>
      </div>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Device Analytics</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Device analytics will be implemented here</p>
            <p className="text-sm mt-2">This will show shared devices, fraud flags, and risk analysis</p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Fraud Detection</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Fraud detection features will be implemented here</p>
            <p className="text-sm mt-2">This will show flagged accounts and suspicious activity</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

import React from 'react';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';

export const ApiUsage: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">API Usage Analytics</h1>
        <p className="text-gray-600">Monitor API usage and costs</p>
      </div>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Usage Statistics</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>API usage statistics will be implemented here</p>
            <p className="text-sm mt-2">This will show total requests, costs, and usage patterns</p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Cost Analysis</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Cost analysis charts will be implemented here</p>
            <p className="text-sm mt-2">This will show monthly costs and usage trends</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

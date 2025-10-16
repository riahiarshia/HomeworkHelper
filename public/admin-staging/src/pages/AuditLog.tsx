import React from 'react';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';

export const AuditLog: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Audit Log</h1>
        <p className="text-gray-600">View system activity and admin actions</p>
      </div>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Recent Activity</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Audit log will be implemented here</p>
            <p className="text-sm mt-2">This will show recent admin actions and system events</p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <h3 className="text-lg font-semibold">Search & Filter</h3>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <p>Audit log search and filtering will be implemented here</p>
            <p className="text-sm mt-2">This will allow searching by user, action, date, etc.</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

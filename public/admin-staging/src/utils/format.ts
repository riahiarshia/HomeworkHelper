// Date formatting
export const formatDate = (dateString: string | null | undefined): string => {
  if (!dateString) return '-';
  
  try {
    const date = new Date(dateString);
    if (isNaN(date.getTime())) return '-';
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  } catch {
    return '-';
  }
};

export const formatDateOnly = (dateString: string | null | undefined): string => {
  if (!dateString) return '-';
  
  try {
    const date = new Date(dateString);
    if (isNaN(date.getTime())) return '-';
    return date.toLocaleDateString();
  } catch {
    return '-';
  }
};

export const formatDateTimeLocal = (date: Date): string => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day}T${hours}:${minutes}`;
};

// Number formatting
export const formatNumber = (num: number | null | undefined): string => {
  if (num === null || num === undefined) return '0';
  return parseInt(num.toString()).toLocaleString();
};

export const formatCurrency = (amount: number | null | undefined): string => {
  if (amount === null || amount === undefined) return '$0.00';
  return '$' + parseFloat(amount.toString()).toFixed(4);
};

export const formatPercentage = (value: number | null | undefined): string => {
  if (value === null || value === undefined) return '0%';
  return parseFloat(value.toString()).toFixed(1) + '%';
};

// Text formatting
export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};

export const capitalizeFirst = (text: string): string => {
  return text.charAt(0).toUpperCase() + text.slice(1);
};

export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// Status formatting
export const getStatusColor = (status: string): string => {
  const statusColors: Record<string, string> = {
    active: 'text-success-600 bg-success-50',
    trial: 'text-blue-600 bg-blue-50',
    expired: 'text-danger-600 bg-danger-50',
    cancelled: 'text-warning-600 bg-warning-50',
    banned: 'text-danger-600 bg-danger-50',
    promo_active: 'text-success-600 bg-success-50',
  };
  
  return statusColors[status] || 'text-gray-600 bg-gray-50';
};

export const getSubscriptionBadgeClass = (status: string): string => {
  const badgeClasses: Record<string, string> = {
    active: 'bg-success-100 text-success-800',
    trial: 'bg-blue-100 text-blue-800',
    expired: 'bg-danger-100 text-danger-800',
    cancelled: 'bg-warning-100 text-warning-800',
    banned: 'bg-danger-100 text-danger-800',
    promo_active: 'bg-success-100 text-success-800',
  };
  
  return badgeClasses[status] || 'bg-gray-100 text-gray-800';
};

// Risk level formatting
export const getRiskLevel = (accountCount: number, totalLogins: number): 'Low' | 'Medium' | 'High' => {
  if (accountCount > 5 || totalLogins > 100) return 'High';
  if (accountCount > 3 || totalLogins > 50) return 'Medium';
  return 'Low';
};

export const getRiskColor = (riskLevel: string): string => {
  const riskColors: Record<string, string> = {
    High: '#ef4444',
    Medium: '#f59e0b',
    Low: '#22c55e',
  };
  
  return riskColors[riskLevel] || '#6b7280';
};

export const getRiskClass = (riskLevel: string): string => {
  const riskClasses: Record<string, string> = {
    High: 'bg-danger-100 text-danger-800',
    Medium: 'bg-warning-100 text-warning-800',
    Low: 'bg-success-100 text-success-800',
  };
  
  return riskClasses[riskLevel] || 'bg-gray-100 text-gray-800';
};

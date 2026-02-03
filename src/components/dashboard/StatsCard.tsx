import React from 'react';
import { Card } from '../ui/Card';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: string;
  subtitle?: string;
}

export const StatsCard: React.FC<StatsCardProps> = ({ title, value, icon, subtitle }) => {
  return (
    <Card className="relative overflow-hidden">
      {/* Gradient accent hello*/}
      <div className="absolute top-0 left-0 w-1 h-full bg-gradient-to-b from-blue-600 to-purple-600" />
      
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-500 mb-2">
            {title}
          </p>
          <h2 className="text-4xl font-bold text-gray-900 mb-1">{value}</h2>
          {subtitle && (
            <p className="text-sm text-gray-500 mt-1">
              {subtitle}
            </p>
          )}
        </div>
        <div className="w-16 h-16 bg-gradient-to-br from-blue-100 to-purple-100 rounded-2xl flex items-center justify-center text-3xl">
          {icon}
        </div>
      </div>
    </Card>
  );
};
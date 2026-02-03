import React from 'react';
import { Card } from '../ui/Card';
import { Appointment } from '../../types';
import { format } from 'date-fns';
import { useNavigate } from 'react-router-dom';

interface AppointmentCardProps {
  appointment: Appointment;
}

type AppointmentRow = Appointment & { parent_name?: string; scheduled_at?: string };

export const AppointmentCard: React.FC<AppointmentCardProps> = ({ appointment }) => {
  const navigate = useNavigate();

  const getStatusStyles = (status: string) => {
    switch (status) {
      case 'confirmed': return 'bg-green-100 text-green-700 border-green-200';
      case 'requested': return 'bg-yellow-100 text-yellow-700 border-yellow-200';
      case 'completed': return 'bg-gray-100 text-gray-700 border-gray-200';
      case 'cancelled': return 'bg-red-100 text-red-700 border-red-200';
      default: return 'bg-gray-100 text-gray-700 border-gray-200';
    }
  };

  const appt = appointment as AppointmentRow;
  const displayName = appt.parent_name ?? appt.client_name ?? 'Client';
  const displayTime = appt.scheduled_at ?? appt.scheduled_for;

  return (
    <Card onClick={() => navigate(`/chat/${appointment.id}`)}>
      <div className="flex justify-between items-center">
        <div className="flex items-center space-x-4">
          {/* Avatar */}
          <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
            {displayName.charAt(0).toUpperCase()}
          </div>
          
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-1">
              {displayName}
            </h3>
            <div className="flex items-center space-x-2 text-sm text-gray-500">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span>{format(new Date(displayTime), 'MMM dd, yyyy • hh:mm a')}</span>
            </div>
          </div>
        </div>
        
        <span className={`px-3 py-1.5 rounded-full text-xs font-semibold border ${getStatusStyles(appointment.status)} capitalize`}>
          {appointment.status}
        </span>
      </div>
    </Card>
  );
};
import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
}

export const Card: React.FC<CardProps> = ({ children, className = '', onClick }) => {
  return (
    <div
      onClick={onClick}
      className={`
        bg-white rounded-2xl p-6 shadow-lg border border-gray-100
        transition-all duration-300
        ${onClick ? 'cursor-pointer card-hover' : ''}
        ${className}
      `}
    >
      {children}
    </div>
  );
};
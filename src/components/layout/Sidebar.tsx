import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const navItems = [
  { 
    path: '/dashboard', 
    label: 'Dashboard', 
    icon: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
      </svg>
    )
  },
  { 
    path: '/appointments', 
    label: 'Appointments', 
    icon: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
    )
  },
  { 
    path: '/availability', 
    label: 'Availability', 
    icon: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    )
  },
  { 
    path: '/earnings', 
    label: 'Earnings', 
    icon: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    )
  },
];

export const Sidebar: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <aside className="w-64 bg-gradient-to-b from-white via-purple-50/30 to-violet-50/50 border-r border-purple-100 h-[calc(100vh-73px)] sticky top-[73px]">
      <nav className="p-4 space-y-2">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`
                w-full flex items-center space-x-3 px-4 py-3.5 rounded-xl font-medium transition-all duration-200
                ${isActive 
                  ? 'bg-gradient-to-r from-purple-600 to-violet-600 text-white shadow-lg shadow-purple-500/40 scale-[1.02]' 
                  : 'text-gray-700 hover:bg-purple-50 hover:text-purple-700 hover:scale-[1.01] active:scale-95'
                }
              `}
            >
              <span className={isActive ? 'text-white' : 'text-purple-500'}>
                {item.icon}
              </span>
              <span className="flex-1 text-left">{item.label}</span>
              {isActive && (
                <span className="ml-auto w-2 h-2 bg-white rounded-full animate-pulse shadow-lg"></span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Quick Stats */}
      <div className="px-4 mt-8">
        <div className="bg-gradient-to-br from-purple-100 via-violet-100 to-purple-50 rounded-2xl p-5 border border-purple-200/50 shadow-lg shadow-purple-500/10">
          <div className="flex items-center space-x-2 mb-3">
            <div className="w-9 h-9 bg-gradient-to-br from-purple-600 via-violet-600 to-purple-700 rounded-xl flex items-center justify-center shadow-lg shadow-purple-500/30">
              <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
              </svg>
            </div>
            <p className="text-sm font-semibold text-purple-700">This Month</p>
          </div>
          <p className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-violet-600 bg-clip-text text-transparent">$3,300</p>
          <p className="text-xs text-purple-600 mt-2 flex items-center space-x-1">
            <span className="text-green-600 font-semibold">↑ 12%</span>
            <span>from last month</span>
          </p>
        </div>
      </div>
    </aside>
  );
};
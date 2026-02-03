import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { ProfileModal } from '../profile/ProfileModal';

export const Navbar: React.FC = () => {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);

  const handleSignOut = async () => {
    await signOut();
    navigate('/login');
  };

  return (
    <nav className="sticky top-0 z-50 bg-white border-b border-purple-100 shadow-sm">
      <div className="w-full px-6 py-3.5">
        <div className="flex items-center justify-between">
          {/* Logo - Left Aligned */}
          <div className="flex items-center space-x-3 flex-shrink-0">
            <div className="w-11 h-11 bg-gradient-to-br from-purple-500 via-violet-500 to-purple-600 rounded-xl flex items-center justify-center shadow-lg shadow-purple-500/30">
              <span className="text-white text-xl font-bold">E</span>
            </div>
            <div>
              <h1 className="text-xl font-bold bg-gradient-to-r from-purple-600 to-violet-600 bg-clip-text text-transparent">
                Expert Portal
              </h1>
              <p className="text-xs text-purple-600/70">Professional Dashboard</p>
            </div>
          </div>

          {/* User Menu - Right Aligned */}
          {user && (
            <div className="flex items-center space-x-3 ml-auto">
              {/* Notifications */}
              <button className="relative p-2.5 hover:bg-purple-50 rounded-xl transition-colors group">
                <svg className="w-6 h-6 text-gray-600 group-hover:text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-gradient-to-r from-red-500 to-pink-500 rounded-full animate-pulse"></span>
              </button>

              {/* User Profile */}
              <div 
                className="flex items-center space-x-3 px-4 py-2 border-l border-purple-200 cursor-pointer hover:bg-purple-50 rounded-lg transition-colors"
                onClick={() => setIsProfileModalOpen(true)}
              >
                <div className="text-right">
                  <p className="text-sm font-semibold text-gray-900">{user.email.split('@')[0]}</p>
                  <p className="text-xs text-purple-600">Expert Account</p>
                </div>
                <div className="w-10 h-10 bg-gradient-to-br from-purple-500 via-violet-500 to-purple-600 rounded-full flex items-center justify-center text-white font-semibold shadow-lg shadow-purple-500/30">
                  {user.email[0].toUpperCase()}
                </div>
              </div>

              {/* Sign Out */}
              <button
                onClick={handleSignOut}
                className="flex items-center space-x-2 px-4 py-2.5 rounded-xl text-sm font-medium text-gray-700 hover:bg-red-50 hover:text-red-600 transition-all duration-200 border border-transparent hover:border-red-200"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                <span>Logout</span>
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Profile Modal */}
      <ProfileModal 
        isOpen={isProfileModalOpen} 
        onClose={() => setIsProfileModalOpen(false)} 
      />
    </nav>
  );
};
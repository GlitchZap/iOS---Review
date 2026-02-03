const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware - CORS must be first
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 86400 // 24 hours
}));

// Handle preflight requests
app.options('*', cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes - Using Supabase versions
app.use('/api/auth', require('./routes/auth.supabase'));
app.use('/api/appointments', require('./routes/appointments.supabase'));
app.use('/api/availability', require('./routes/availability.supabase'));
app.use('/api/messages', require('./routes/messages.supabase'));
app.use('/api/earnings', require('./routes/earnings.supabase'));

// Health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Expert Portal API is running',
    timestamp: new Date().toISOString()
  });
});

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to Expert Portal API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      appointments: '/api/appointments',
      availability: '/api/availability',
      messages: '/api/messages',
      earnings: '/api/earnings',
      health: '/health'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`\n🚀 Server running on port ${PORT}`);
  console.log(`📍 API URL: http://localhost:${PORT}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health\n`);
});

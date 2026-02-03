# Expert Portal Backend API

Complete Node.js + MySQL backend for the Expert Portal application.

## 🚀 Quick Start

### Prerequisites
- Node.js (v14 or higher)
- MySQL (v5.7 or higher)
- npm or yarn

### Installation Steps

1. **Navigate to backend directory:**
```bash
cd backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Setup MySQL Database:**

First, make sure MySQL is running on your system.

```bash
# Login to MySQL
mysql -u root -p

# Create database (or run the schema file)
CREATE DATABASE expert_portal;
```

Then run the schema file:
```bash
mysql -u root -p expert_portal < database/schema.sql
```

4. **Configure Environment Variables:**

Create a `.env` file in the backend directory:
```bash
cp .env.example .env
```

Edit `.env` with your database credentials:
```env
PORT=5000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=expert_portal

JWT_SECRET=your_super_secret_jwt_key_change_this
JWT_EXPIRE=7d
```

5. **Start the server:**

Development mode (with auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

The server will start on `http://localhost:5000`

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new expert
- `POST /api/auth/login` - Login expert
- `GET /api/auth/me` - Get current expert info

### Appointments
- `GET /api/appointments` - Get all appointments
- `GET /api/appointments/:id` - Get single appointment
- `PUT /api/appointments/:id` - Update appointment
- `GET /api/appointments/stats/dashboard` - Get dashboard stats

### Availability
- `GET /api/availability` - Get availability slots
- `POST /api/availability` - Add availability slot
- `DELETE /api/availability/:id` - Delete availability slot

### Messages
- `GET /api/messages/:appointmentId` - Get messages for appointment
- `POST /api/messages` - Send a message
- `PUT /api/messages/read/:appointmentId` - Mark messages as read

### Earnings
- `GET /api/earnings` - Get earnings summary
- `GET /api/earnings/payouts` - Get payout history
- `POST /api/earnings/request-payout` - Request payout

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication. After login, include the token in requests:

```javascript
headers: {
  'Authorization': 'Bearer YOUR_JWT_TOKEN'
}
```

## 📊 Database Schema

The database includes the following tables:
- **experts** - Expert user accounts
- **clients** - Client user accounts
- **appointments** - Booking appointments
- **availability** - Expert availability schedule
- **messages** - Chat messages
- **earnings** - Individual earnings records
- **payouts** - Payout transactions

## 🧪 Testing the API

### 1. Health Check
```bash
curl http://localhost:5000/health
```

### 2. Register an Expert
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "expert@test.com",
    "password": "password123",
    "full_name": "Test Expert"
  }'
```

### 3. Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "expert@test.com",
    "password": "password123"
  }'
```

### 4. Get Appointments (use token from login)
```bash
curl http://localhost:5000/api/appointments \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🔧 Troubleshooting

### MySQL Connection Error
```
Error: connect ECONNREFUSED
```
- Make sure MySQL is running
- Check your DB credentials in `.env`
- Verify database exists: `SHOW DATABASES;` in MySQL

### JWT Secret Error
```
Error: secretOrPrivateKey must have a value
```
- Make sure JWT_SECRET is set in `.env`
- Restart the server after changing `.env`

### Port Already in Use
```
Error: listen EADDRINUSE :::5000
```
- Change PORT in `.env` to another port (e.g., 5001)
- Or kill the process using port 5000

## 📁 Project Structure

```
backend/
├── config/
│   └── database.js          # MySQL connection pool
├── middleware/
│   └── auth.js              # JWT authentication middleware
├── routes/
│   ├── auth.js              # Authentication routes
│   ├── appointments.js      # Appointment routes
│   ├── availability.js      # Availability routes
│   ├── messages.js          # Message routes
│   └── earnings.js          # Earnings routes
├── database/
│   └── schema.sql           # Database schema
├── .env.example             # Environment variables template
├── server.js                # Main server file
├── package.json             # Dependencies
└── README.md                # This file
```

## 🔒 Security Features

- Password hashing with bcrypt
- JWT token authentication
- Input validation with express-validator
- SQL injection protection with parameterized queries
- CORS configuration
- Rate limiting (recommended for production)

## 📝 Sample Data

The schema includes sample data for testing:
- Demo expert: `expert@demo.com` / password (set your own)
- Sample appointments
- Sample messages
- Sample availability slots

## 🌐 Connecting Frontend

Update your frontend `.env`:
```env
REACT_APP_API_URL=http://localhost:5000/api
```

Then update the API calls in your React app to use real endpoints instead of mock data.

## 🚢 Production Deployment

For production:
1. Set `NODE_ENV=production`
2. Use strong JWT_SECRET
3. Enable HTTPS
4. Add rate limiting
5. Setup proper MySQL user (not root)
6. Add logging
7. Setup monitoring
8. Use environment-specific configs

## 📞 Support

For issues or questions, check:
- MySQL is running and accessible
- All environment variables are set
- Database schema is properly created
- Node.js dependencies are installed

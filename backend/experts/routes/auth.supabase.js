const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const supabase = require('../config/supabase');

// Generate JWT Token
const generateToken = (id, email) => {
  return jwt.sign({ id, email }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '7d'
  });
};

// @route   POST /api/auth/register
// @desc    Register new expert
// @access  Public
router.post('/register', [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('full_name').notEmpty().withMessage('Full name is required')
], async (req, res) => {
  try {
    // Validation
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { email, password, full_name, phone, bio, expertise, hourly_rate } = req.body;

    // Check if expert exists
    const { data: existing, error: checkError } = await supabase
      .from('experts')
      .select('id')
      .eq('email', email)
      .single();

    if (existing) {
      return res.status(400).json({ success: false, message: 'Expert already exists with this email' });
    }

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });

    if (authError) {
      console.error('Supabase auth error:', authError);
      return res.status(400).json({ success: false, message: authError.message });
    }

    // Hash password for our records (backup)
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Create expert profile
    const { data: expert, error: insertError } = await supabase
      .from('experts')
      .insert({
        auth_user_id: authData.user.id,
        email,
        full_name,
        bio: bio || null,
        expertise: expertise ? [expertise] : [],
        hourly_rate: hourly_rate || 150.00
      })
      .select()
      .single();

    if (insertError) {
      console.error('Insert error:', insertError);
      // Try to clean up the auth user if profile creation fails
      await supabase.auth.admin.deleteUser(authData.user.id);
      return res.status(500).json({ success: false, message: 'Failed to create expert profile' });
    }

    // Generate token
    const token = generateToken(expert.id, email);

    res.status(201).json({
      success: true,
      message: 'Expert registered successfully',
      token,
      expert: {
        id: expert.id,
        email,
        full_name
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
});

// @route   POST /api/auth/login
// @desc    Login expert
// @access  Public
router.post('/login', [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  try {
    // Validation
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { email, password } = req.body;

    // Sign in with Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (authError) {
      console.error('Login auth error:', authError);
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Get expert profile
    const { data: expert, error: profileError } = await supabase
      .from('experts')
      .select('*')
      .eq('auth_user_id', authData.user.id)
      .single();

    if (profileError || !expert) {
      return res.status(401).json({ success: false, message: 'Expert profile not found' });
    }

    // Generate our own token (or use Supabase's)
    const token = generateToken(expert.id, expert.email);

    res.json({
      success: true,
      message: 'Login successful',
      token,
      expert: {
        id: expert.id,
        email: expert.email,
        full_name: expert.full_name,
        expertise: expert.expertise,
        hourly_rate: expert.hourly_rate,
        rating: expert.rating
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
});

// @route   GET /api/auth/me
// @desc    Get current expert
// @access  Private
router.get('/me', async (req, res) => {
  try {
    // Get token from header
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Get expert data
    const { data: expert, error } = await supabase
      .from('experts')
      .select('*')
      .eq('id', decoded.id)
      .single();

    if (error || !expert) {
      return res.status(404).json({ success: false, message: 'Expert not found' });
    }

    res.json({
      success: true,
      expert: {
        id: expert.id,
        email: expert.email,
        full_name: expert.full_name,
        bio: expert.bio,
        expertise: expert.expertise,
        hourly_rate: expert.hourly_rate,
        rating: expert.rating,
        total_reviews: expert.total_reviews,
        verified: expert.verified,
        profile_image_url: expert.profile_image_url,
        created_at: expert.created_at
      }
    });
  } catch (error) {
    console.error('Get me error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   PUT /api/auth/profile
// @desc    Update expert profile
// @access  Private
router.put('/profile', async (req, res) => {
  try {
    // Get token from header
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { 
      full_name, 
      phone, 
      bio, 
      expertise, 
      hourly_rate, 
      experience_years,
      education,
      languages,
      certificates 
    } = req.body;

    // Validate required fields
    if (!full_name) {
      return res.status(400).json({ success: false, message: 'Full name is required' });
    }

    // Build update object
    const updates = {
      full_name,
      bio: bio || null,
      expertise: expertise ? (Array.isArray(expertise) ? expertise : [expertise]) : [],
      hourly_rate: hourly_rate || 150.00,
      updated_at: new Date().toISOString()
    };

    // Update expert profile
    const { data: expert, error } = await supabase
      .from('experts')
      .update(updates)
      .eq('id', decoded.id)
      .select()
      .single();

    if (error) {
      console.error('Update error:', error);
      return res.status(500).json({ success: false, message: 'Failed to update profile' });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      expert
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;

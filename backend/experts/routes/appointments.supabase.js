const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { protect } = require('../middleware/auth');

// @route   GET /api/appointments
// @desc    Get all appointments for logged-in expert
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const { status, limit = 50 } = req.query;
    
    let query = supabase
      .from('appointments')
      .select('*')
      .eq('expert_id', req.expert.id)
      .order('scheduled_for', { ascending: false })
      .limit(parseInt(limit));

    if (status) {
      query = query.eq('status', status);
    }

    const { data: appointments, error } = await query;

    if (error) {
      console.error('Get appointments error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    res.json({
      success: true,
      count: appointments.length,
      appointments
    });
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/appointments/:id
// @desc    Get single appointment
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const { data: appointment, error } = await supabase
      .from('appointments')
      .select('*')
      .eq('id', req.params.id)
      .eq('expert_id', req.expert.id)
      .single();

    if (error || !appointment) {
      return res.status(404).json({ success: false, message: 'Appointment not found' });
    }

    res.json({
      success: true,
      appointment
    });
  } catch (error) {
    console.error('Get appointment error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   PUT /api/appointments/:id
// @desc    Update appointment status
// @access  Private
router.put('/:id', protect, async (req, res) => {
  try {
    const { status, notes, rating, feedback } = req.body;

    // Verify appointment belongs to expert
    const { data: existing, error: checkError } = await supabase
      .from('appointments')
      .select('id')
      .eq('id', req.params.id)
      .eq('expert_id', req.expert.id)
      .single();

    if (checkError || !existing) {
      return res.status(404).json({ success: false, message: 'Appointment not found' });
    }

    // Build update object
    const updates = {
      updated_at: new Date().toISOString()
    };

    if (status) updates.status = status;
    if (notes) updates.notes = notes;
    if (rating) updates.rating = rating;
    if (feedback) updates.feedback = feedback;

    if (Object.keys(updates).length === 1) {
      return res.status(400).json({ success: false, message: 'No fields to update' });
    }

    const { data: updated, error } = await supabase
      .from('appointments')
      .update(updates)
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) {
      console.error('Update error:', error);
      return res.status(500).json({ success: false, message: 'Failed to update appointment' });
    }

    res.json({
      success: true,
      message: 'Appointment updated successfully',
      appointment: updated
    });
  } catch (error) {
    console.error('Update appointment error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/appointments/stats/dashboard
// @desc    Get appointment statistics
// @access  Private
router.get('/stats/dashboard', protect, async (req, res) => {
  try {
    const now = new Date().toISOString();

    // Get upcoming confirmed appointments
    const { count: upcoming } = await supabase
      .from('appointments')
      .select('*', { count: 'exact', head: true })
      .eq('expert_id', req.expert.id)
      .eq('status', 'confirmed')
      .gt('scheduled_for', now);

    // Get completed appointments count
    const { count: completed } = await supabase
      .from('appointments')
      .select('*', { count: 'exact', head: true })
      .eq('expert_id', req.expert.id)
      .eq('status', 'completed');

    // Get total earnings from completed appointments
    const { data: earningsData } = await supabase
      .from('appointments')
      .select('amount')
      .eq('expert_id', req.expert.id)
      .eq('status', 'completed');

    const totalEarnings = earningsData?.reduce((sum, a) => sum + parseFloat(a.amount || 0), 0) || 0;

    res.json({
      success: true,
      stats: {
        upcoming: upcoming || 0,
        completed: completed || 0,
        earnings: totalEarnings
      }
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;

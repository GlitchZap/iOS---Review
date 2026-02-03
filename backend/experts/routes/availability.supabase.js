const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { protect } = require('../middleware/auth');

// @route   GET /api/availability
// @desc    Get expert's availability
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const { data: availability, error } = await supabase
      .from('availability')
      .select('*')
      .eq('expert_id', req.expert.id)
      .order('day_of_week', { ascending: true })
      .order('start_time', { ascending: true });

    if (error) {
      console.error('Get availability error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    res.json({
      success: true,
      count: availability.length,
      availability
    });
  } catch (error) {
    console.error('Get availability error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   POST /api/availability
// @desc    Add availability slot
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { day_of_week, start_time, end_time } = req.body;

    if (day_of_week === undefined || !start_time || !end_time) {
      return res.status(400).json({
        success: false,
        message: 'Please provide day_of_week, start_time, and end_time'
      });
    }

    // Check for existing slot with same exact time
    const { data: existing, error: checkError } = await supabase
      .from('availability')
      .select('id')
      .eq('expert_id', req.expert.id)
      .eq('day_of_week', day_of_week)
      .eq('start_time', start_time)
      .eq('end_time', end_time);

    if (existing && existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'This exact time slot already exists'
      });
    }

    const { data: newSlot, error } = await supabase
      .from('availability')
      .insert({
        expert_id: req.expert.id,
        day_of_week,
        start_time,
        end_time,
        is_available: true
      })
      .select()
      .single();

    if (error) {
      console.error('Add availability error:', error);
      if (error.code === '23505') {
        return res.status(400).json({
          success: false,
          message: 'This exact time slot already exists'
        });
      }
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    res.status(201).json({
      success: true,
      message: 'Availability added successfully',
      availability: newSlot
    });
  } catch (error) {
    console.error('Add availability error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   DELETE /api/availability/:id
// @desc    Delete availability slot
// @access  Private
router.delete('/:id', protect, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('availability')
      .delete()
      .eq('id', req.params.id)
      .eq('expert_id', req.expert.id)
      .select();

    if (error) {
      console.error('Delete availability error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Availability slot not found'
      });
    }

    res.json({
      success: true,
      message: 'Availability slot deleted successfully'
    });
  } catch (error) {
    console.error('Delete availability error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;

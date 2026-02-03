const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { protect } = require('../middleware/auth');

// @route   GET /api/messages/:appointmentId
// @desc    Get messages for an appointment
// @access  Private
router.get('/:appointmentId', protect, async (req, res) => {
  try {
    // Verify appointment belongs to expert
    const { data: appointment, error: checkError } = await supabase
      .from('appointments')
      .select('id')
      .eq('id', req.params.appointmentId)
      .eq('expert_id', req.expert.id)
      .single();

    if (checkError || !appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    const { data: messages, error } = await supabase
      .from('messages')
      .select('*')
      .eq('appointment_id', req.params.appointmentId)
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Get messages error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    res.json({
      success: true,
      count: messages.length,
      messages
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   POST /api/messages
// @desc    Send a message
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { appointment_id, message } = req.body;

    if (!appointment_id || !message) {
      return res.status(400).json({
        success: false,
        message: 'Please provide appointment_id and message'
      });
    }

    // Verify appointment belongs to expert and get expert name
    const { data: appointment, error: checkError } = await supabase
      .from('appointments')
      .select('id')
      .eq('id', appointment_id)
      .eq('expert_id', req.expert.id)
      .single();

    if (checkError || !appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    // Get expert name
    const { data: expert } = await supabase
      .from('experts')
      .select('full_name')
      .eq('id', req.expert.id)
      .single();

    const { data: newMessage, error } = await supabase
      .from('messages')
      .insert({
        appointment_id,
        sender_type: 'expert',
        sender_name: expert?.full_name || 'Expert',
        content: message
      })
      .select()
      .single();

    if (error) {
      console.error('Send message error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: newMessage
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   PUT /api/messages/read/:appointmentId
// @desc    Mark messages as read
// @access  Private
router.put('/read/:appointmentId', protect, async (req, res) => {
  try {
    // Note: The Supabase schema doesn't have is_read field
    // This is a placeholder - you may need to add this field to the schema
    res.json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (error) {
    console.error('Mark read error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;

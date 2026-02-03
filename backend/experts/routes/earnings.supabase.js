const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { protect } = require('../middleware/auth');

// @route   GET /api/earnings
// @desc    Get earnings summary
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    // Get all earnings for this expert
    const { data: earnings, error } = await supabase
      .from('earnings')
      .select('amount, status')
      .eq('expert_id', req.expert.id);

    if (error) {
      console.error('Get earnings error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    // Calculate totals
    const total = earnings?.reduce((sum, e) => sum + parseFloat(e.amount || 0), 0) || 0;
    const pending = earnings?.filter(e => e.status === 'pending')
      .reduce((sum, e) => sum + parseFloat(e.amount || 0), 0) || 0;
    const paid = earnings?.filter(e => e.status === 'paid')
      .reduce((sum, e) => sum + parseFloat(e.amount || 0), 0) || 0;

    res.json({
      success: true,
      earnings: {
        total,
        pending,
        paid
      }
    });
  } catch (error) {
    console.error('Get earnings error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/earnings/payouts
// @desc    Get payout history
// @access  Private
router.get('/payouts', protect, async (req, res) => {
  try {
    const { data: payouts, error } = await supabase
      .from('payouts')
      .select('*')
      .eq('expert_id', req.expert.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Get payouts error:', error);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    res.json({
      success: true,
      count: payouts?.length || 0,
      payouts: payouts || []
    });
  } catch (error) {
    console.error('Get payouts error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   POST /api/earnings/request-payout
// @desc    Request a payout
// @access  Private
router.post('/request-payout', protect, async (req, res) => {
  try {
    // Get pending earnings
    const { data: pendingEarnings, error: earningsError } = await supabase
      .from('earnings')
      .select('id, amount')
      .eq('expert_id', req.expert.id)
      .eq('status', 'pending');

    if (earningsError) {
      console.error('Get pending earnings error:', earningsError);
      return res.status(500).json({ success: false, message: 'Server error' });
    }

    const amount = pendingEarnings?.reduce((sum, e) => sum + parseFloat(e.amount || 0), 0) || 0;

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'No pending earnings to payout'
      });
    }

    // Create payout request
    const { data: newPayout, error: payoutError } = await supabase
      .from('payouts')
      .insert({
        expert_id: req.expert.id,
        amount,
        status: 'pending'
      })
      .select()
      .single();

    if (payoutError) {
      console.error('Create payout error:', payoutError);
      return res.status(500).json({ success: false, message: 'Failed to create payout request' });
    }

    // Update earnings to link them to this payout (mark as processing)
    const earningIds = pendingEarnings.map(e => e.id);
    if (earningIds.length > 0) {
      await supabase
        .from('earnings')
        .update({ status: 'paid', payment_date: new Date().toISOString() })
        .in('id', earningIds);
    }

    res.status(201).json({
      success: true,
      message: 'Payout requested successfully',
      payout: newPayout
    });
  } catch (error) {
    console.error('Request payout error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;

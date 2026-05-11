const express = require('express');
const router = express.Router();
const { success } = require('../utils/response');

/**
 * GET /api/health
 * Health check endpoint.
 */
router.get('/health', (req, res) => {
  res.json(
    success(
      {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
      },
      'Server is healthy'
    )
  );
});

module.exports = router;

const rateLimit = require('express-rate-limit');
const logger = require('../utils/logger');
const { error } = require('../utils/response');

const rateLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 60 * 1000, // 1 minute default
  max: parseInt(process.env.RATE_LIMIT_MAX, 10) || 20, // 20 requests per window default
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json(
      error('Too many requests. Please try again later.', 429)
    );
  },
  skip: (req) => {
    // Skip rate limiting for health check
    return req.path === '/api/health';
  },
});

module.exports = rateLimiter;

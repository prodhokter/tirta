const express = require('express');
const helmet = require('helmet');
const { error } = require('./src/utils/response');
const corsMiddleware = require('./src/middleware/cors.middleware');
const rateLimiter = require('./src/middleware/ratelimit.middleware');
const mountRoutes = require('./src/routes/index');
const logger = require('./src/utils/logger');

const app = express();

// ── Security ────────────────────────────────────────────────────────────────
app.use(helmet());

// ── CORS ────────────────────────────────────────────────────────────────────
app.use(corsMiddleware);

// ── Body parsing ────────────────────────────────────────────────────────────
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Global rate limiter (applies to all /api routes) ────────────────────────
app.use('/api', rateLimiter);

// ── Routes ──────────────────────────────────────────────────────────────────
mountRoutes(app);

// ── 404 handler ─────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json(error('Endpoint not found', 404));
});

// ── Global error handler ────────────────────────────────────────────────────
app.use((err, req, res, _next) => {
  logger.error('Unhandled error:', err);

  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json(error('CORS policy: origin not allowed', 403));
  }

  res.status(500).json(error('Internal server error', 500));
});

module.exports = app;

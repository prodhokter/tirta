const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');
const { error } = require('../utils/response');

/**
 * Extract and verify Supabase JWT from Authorization header.
 * Attaches decoded user info to req.user on success.
 */
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json(error('Missing or invalid Authorization header. Format: Bearer <token>', 401));
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json(error('No token provided', 401));
  }

  try {
    // Supabase JWTs are signed with the service key (JWT secret)
    const secret = process.env.SUPABASE_SERVICE_KEY;

    if (!secret) {
      logger.error('SUPABASE_SERVICE_KEY is not configured');
      return res.status(500).json(error('Server configuration error', 500));
    }

    const decoded = jwt.verify(token, secret, {
      algorithms: ['HS256'],
    });

    // Attach user info to request
    req.user = {
      id: decoded.sub,
      email: decoded.email,
      role: decoded.role,
      aud: decoded.aud,
    };

    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json(error('Token expired. Please sign in again.', 401));
    }
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json(error('Invalid token', 401));
    }
    logger.error('Auth middleware error:', err);
    return res.status(401).json(error('Authentication failed', 401));
  }
};

module.exports = authMiddleware;

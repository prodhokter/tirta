const https = require('https');
const logger = require('../utils/logger');
const { error } = require('../utils/response');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

/**
 * Verify Supabase JWT by calling Supabase Auth API.
 * Attaches decoded user info to req.user on success.
 */
function verifySupabaseToken(token) {
  return new Promise((resolve, reject) => {
    const url = new URL(SUPABASE_URL);
    const options = {
      hostname: url.hostname,
      path: '/auth/v1/user',
      method: 'GET',
      headers: {
        Authorization: `Bearer ${token}`,
        apikey: SUPABASE_ANON_KEY,
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error('Invalid response from auth server'));
          }
        } else if (res.statusCode === 401) {
          reject(new Error('Token expired or invalid'));
        } else {
          reject(new Error(`Auth server error: ${res.statusCode}`));
        }
      });
    });

    req.on('error', (err) => {
      logger.error('Supabase auth verification network error:', err.message);
      reject(new Error('Auth verification failed — network error'));
    });

    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Auth verification timed out'));
    });

    req.end();
  });
}

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json(error('Missing or invalid Authorization header. Format: Bearer <token>', 401));
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json(error('No token provided', 401));
  }

  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    logger.error('SUPABASE_URL or SUPABASE_ANON_KEY is not configured');
    return res.status(500).json(error('Server configuration error', 500));
  }

  try {
    const userData = await verifySupabaseToken(token);

    req.user = {
      id: userData.id,
      email: userData.email,
      role: userData.role,
      aud: userData.aud,
    };

    next();
  } catch (err) {
    const msg = err.message || 'Authentication failed';

    if (msg.includes('expired') || msg.includes('invalid')) {
      return res.status(401).json(error('Token expired. Please sign in again.', 401));
    }

    logger.error('Auth middleware error:', msg);
    return res.status(401).json(error('Authentication failed', 401));
  }
};

module.exports = authMiddleware;

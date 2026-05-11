const express = require('express');
const router = express.Router();
const aiService = require('../services/ai.service');
const authMiddleware = require('../middleware/auth.middleware');
const rateLimiter = require('../middleware/ratelimit.middleware');
const { success, error } = require('../utils/response');
const logger = require('../utils/logger');

/**
 * POST /api/chat
 * Send messages to the TIRTA AI chatbot.
 * Requires authentication. Rate limited.
 *
 * Body: { messages: [{ role: 'user', content: '...' }] }
 */
router.post('/chat', authMiddleware, rateLimiter, async (req, res) => {
  try {
    const { messages } = req.body;

    // Validate messages array
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json(
        error('messages array is required and must not be empty', 400)
      );
    }

    // Validate each message has role and content
    for (const msg of messages) {
      if (!msg.role || !msg.content) {
        return res.status(400).json(
          error('Each message must have role and content fields', 400)
        );
      }
      if (!['user', 'assistant'].includes(msg.role)) {
        return res.status(400).json(
          error('Message role must be either "user" or "assistant"', 400)
        );
      }
    }

    logger.info(`Chat request from user: ${req.user.id}, messages: ${messages.length}`);

    const response = await aiService.chat(messages);

    res.json(success({ response }, 'Chat response generated'));
  } catch (err) {
    logger.error('Chat route error:', err);

    if (err.message.includes('AI_API_KEY')) {
      return res.status(503).json(
        error('AI service is not configured', 503)
      );
    }

    if (err.status === 429) {
      return res.status(429).json(
        error('AI service rate limit exceeded. Please try again later.', 429)
      );
    }

    if (err.status === 529) {
      return res.status(503).json(
        error('AI service is overloaded. Please try again in a moment.', 503)
      );
    }

    res.status(500).json(
      error('Failed to generate chat response. Please try again.', 500)
    );
  }
});

module.exports = router;

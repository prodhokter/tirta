const express = require('express');
const router = express.Router();
const aiService = require('../services/ai.service');
const authMiddleware = require('../middleware/auth.middleware');
const rateLimiter = require('../middleware/ratelimit.middleware');
const { success, error } = require('../utils/response');
const logger = require('../utils/logger');

function validateMessages(messages) {
  if (!messages || !Array.isArray(messages) || messages.length === 0) {
    return 'messages array is required and must not be empty';
  }
  for (const msg of messages) {
    if (!msg.role || !msg.content) {
      return 'Each message must have role and content fields';
    }
    if (!['user', 'assistant'].includes(msg.role)) {
      return 'Message role must be either "user" or "assistant"';
    }
  }
  return null;
}

/**
 * POST /api/chat
 * Non-streaming chat endpoint.
 */
router.post('/chat', authMiddleware, rateLimiter, async (req, res) => {
  try {
    const { messages } = req.body;
    const validationError = validateMessages(messages);
    if (validationError) {
      return res.status(400).json(error(validationError, 400));
    }

    logger.info(`Chat request from user: ${req.user.id}, messages: ${messages.length}`);

    const response = await aiService.chat(messages);

    res.json(success({ response }, 'Chat response generated'));
  } catch (err) {
    logger.error('Chat route error:', err);

    if (err.message.includes('AI_API_KEY')) {
      return res.status(503).json(error('AI service is not configured', 503));
    }

    if (err.status === 429) {
      return res.status(429).json(error('AI service rate limit exceeded. Please try again later.', 429));
    }

    if (err.status === 529) {
      return res.status(503).json(error('AI service is overloaded. Please try again in a moment.', 503));
    }

    res.status(500).json(error('Failed to generate chat response. Please try again.', 500));
  }
});

/**
 * POST /api/chat/stream
 * Streaming chat endpoint using Server-Sent Events (SSE).
 */
router.post('/chat/stream', authMiddleware, rateLimiter, async (req, res) => {
  try {
    const { messages } = req.body;
    const validationError = validateMessages(messages);
    if (validationError) {
      return res.status(400).json(error(validationError, 400));
    }

    logger.info(`Chat stream request from user: ${req.user.id}, messages: ${messages.length}`);

    // Set SSE headers
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no');
    res.flushHeaders();

    const stream = aiService.chatStream(messages);

    for await (const chunk of stream) {
      res.write(`data: ${JSON.stringify({ content: chunk })}\n\n`);
    }

    res.write('data: [DONE]\n\n');
    res.end();

    logger.info(`Chat stream completed for user: ${req.user.id}`);
  } catch (err) {
    logger.error('Chat stream error:', err);

    if (!res.headersSent) {
      if (err.message.includes('AI_API_KEY')) {
        return res.status(503).json(error('AI service is not configured', 503));
      }
      return res.status(500).json(error('Failed to generate chat response.', 500));
    }

    // Headers already sent, send error as SSE event
    res.write(`data: ${JSON.stringify({ error: 'Stream interrupted. Please try again.' })}\n\n`);
    res.end();
  }
});

module.exports = router;

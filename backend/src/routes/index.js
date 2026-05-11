const healthRoutes = require('./health.routes');
const chatRoutes = require('./chat.routes');

/**
 * Mount all API routes.
 * @param {import('express').Express} app
 */
function mountRoutes(app) {
  app.use('/api', healthRoutes);
  app.use('/api', chatRoutes);
}

module.exports = mountRoutes;

require('dotenv').config();

const app = require('./app');
const logger = require('./src/utils/logger');

const PORT = parseInt(process.env.PORT, 10) || 3000;

app.listen(PORT, () => {
  logger.info(`TIRTA Backend API running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

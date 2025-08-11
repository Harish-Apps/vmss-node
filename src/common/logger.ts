import pino from 'pino';
import appInsights from 'applicationinsights';
import config from './config';

if (config.appInsightsConnection) {
  appInsights.setup(config.appInsightsConnection).setAutoCollectConsole(true).start();
}

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  base: undefined,
});

export default logger;

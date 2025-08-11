import dotenv from 'dotenv';

dotenv.config();

export const config = {
  jwtSecret: process.env.JWT_SECRET || 'local-secret',
  jwtIssuer: process.env.JWT_ISSUER || 'simple-auth-demo',
  serviceBusConnection: process.env.SERVICE_BUS_CONNECTION || '',
  cosmosConnection: process.env.COSMOS_CONNECTION || '',
  appInsightsConnection: process.env.APPINSIGHTS_CONNECTION_STRING,
  queues: {
    userRegistered: process.env.USER_REGISTERED_QUEUE || 'user-registered',
    emailSendRequested: process.env.EMAIL_SEND_REQUESTED_QUEUE || 'email-send-requested'
  },
  cosmos: {
    database: process.env.COSMOS_DB_NAME || 'app',
    usersContainer: process.env.USERS_CONTAINER || 'users',
    processedContainer: process.env.PROCESSED_CONTAINER || 'processedEvents'
  }
};

export default config;

import { AzureFunction, Context } from '@azure/functions';
import { domainEventSchema } from '../../types/events';
import { createEvent, publishEvent } from '../../common/events';
import config from '../../common/config';
import logger from '../../common/logger';
import { hasProcessed, markProcessed } from '../../common/db';

const serviceBusTrigger: AzureFunction = async function (context: Context, message: unknown) {
  const event = domainEventSchema.parse(message);
  if (await hasProcessed(event.eventId)) {
    logger.warn({ eventId: event.eventId }, 'Event already processed');
    return;
  }
  const emailEvent = createEvent('EmailSendRequested', {
    userId: event.data.userId,
    email: event.data.email,
  }, event.traceId);
  await publishEvent(config.queues.emailSendRequested, emailEvent);
  await markProcessed(event.eventId);
  logger.info({ eventId: event.eventId }, 'Processed UserRegistered');
};

export default serviceBusTrigger;

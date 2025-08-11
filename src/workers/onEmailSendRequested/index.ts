import { AzureFunction, Context } from '@azure/functions';
import { domainEventSchema } from '../../types/events';
import logger from '../../common/logger';
import { hasProcessed, markProcessed } from '../../common/db';
import { createEvent } from '../../common/events';

const serviceBusTrigger: AzureFunction = async function (context: Context, message: unknown) {
  const event = domainEventSchema.parse(message);
  if (event.type !== 'EmailSendRequested') {
    logger.warn({ eventType: event.type }, 'Unexpected event type');
    return;
  }
  if (await hasProcessed(event.eventId)) {
    logger.warn({ eventId: event.eventId }, 'Event already processed');
    return;
  }
  logger.info({ to: event.data.email, eventId: event.eventId }, 'Simulating email send');
  const sentEvent = createEvent('EmailSent', {
    userId: event.data.userId,
    email: event.data.email,
  }, event.traceId);
  logger.info({ eventId: sentEvent.eventId }, 'EmailSent event emitted');
  await markProcessed(event.eventId);
};

export default serviceBusTrigger;

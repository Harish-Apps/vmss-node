import { ServiceBusClient } from '@azure/service-bus';
import { v4 as uuid } from 'uuid';
import config from './config';
import { DomainEvent } from '../types/events';

const serviceBusClient = new ServiceBusClient(config.serviceBusConnection);

export function createEvent<T extends DomainEvent['type']>(
  type: T,
  data: any,
  traceId?: string
): DomainEvent {
  return {
    eventId: uuid(),
    type,
    occurredAt: new Date().toISOString(),
    data,
    traceId: traceId || uuid(),
    source: 'user-service',
  } as DomainEvent;
}

export async function publishEvent(queue: string, event: DomainEvent) {
  const sender = serviceBusClient.createSender(queue);
  try {
    await sender.sendMessages({ body: event });
  } finally {
    await sender.close();
  }
}

import { z } from 'zod';

const baseEvent = z.object({
  eventId: z.string().uuid(),
  occurredAt: z.string().datetime(),
  traceId: z.string().uuid(),
  source: z.string(),
});

export const userRegisteredEvent = baseEvent.extend({
  type: z.literal('UserRegistered'),
  data: z.object({
    userId: z.string().uuid(),
    email: z.string().email(),
  }),
});

export const emailSendRequestedEvent = baseEvent.extend({
  type: z.literal('EmailSendRequested'),
  data: z.object({
    userId: z.string().uuid(),
    email: z.string().email(),
  }),
});

export const emailSentEvent = baseEvent.extend({
  type: z.literal('EmailSent'),
  data: z.object({
    userId: z.string().uuid(),
    email: z.string().email(),
  }),
});

export const domainEventSchema = z.union([
  userRegisteredEvent,
  emailSendRequestedEvent,
  emailSentEvent,
]);

export type DomainEvent = z.infer<typeof domainEventSchema>;

import { domainEventSchema } from '../src/types/events';

describe('event validation', () => {
  it('validates UserRegistered event', () => {
    const event = {
      eventId: '11111111-1111-1111-1111-111111111111',
      type: 'UserRegistered',
      occurredAt: new Date().toISOString(),
      data: { userId: '22222222-2222-2222-2222-222222222222', email: 'a@b.com' },
      traceId: '33333333-3333-3333-3333-333333333333',
      source: 'user-service',
    };
    expect(() => domainEventSchema.parse(event)).not.toThrow();
  });
});

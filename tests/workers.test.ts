import { createEvent } from '../src/common/events';
import onUserRegistered from '../src/workers/onUserRegistered';
import onEmailSendRequested from '../src/workers/onEmailSendRequested';
import config from '../src/common/config';
import * as events from '../src/common/events';

jest.mock('../src/common/events');
jest.mock('../src/common/db', () => ({
  hasProcessed: jest.fn().mockResolvedValue(false),
  markProcessed: jest.fn().mockResolvedValue(undefined),
}));

describe('event workflow', () => {
  it('publishes EmailSendRequested when UserRegistered processed', async () => {
    const publishMock = events.publishEvent as jest.Mock;
    publishMock.mockResolvedValue(undefined);
    const userReg = createEvent('UserRegistered', { userId: 'u1', email: 'a@b.com' });
    await onUserRegistered({} as any, userReg);
    expect(publishMock).toHaveBeenCalledWith(
      config.queues.emailSendRequested,
      expect.objectContaining({ type: 'EmailSendRequested' })
    );
  });

  it('processes EmailSendRequested without error', async () => {
    const emailReq = createEvent('EmailSendRequested', { userId: 'u1', email: 'a@b.com' });
    await expect(onEmailSendRequested({} as any, emailReq)).resolves.toBeUndefined();
  });
});

import { AzureFunction, Context, HttpRequest } from '@azure/functions';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import { verifyAuth } from '../../common/auth';
import { createEvent, publishEvent } from '../../common/events';
import config from '../../common/config';
import logger from '../../common/logger';
import { upsertUser } from '../../common/db';
import { v4 as uuid } from 'uuid';

const bodySchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest) {
  try {
    verifyAuth(req.headers['authorization']);
    const body = bodySchema.parse(req.body);
    const userId = uuid();
    const passwordHash = await bcrypt.hash(body.password, 10);
    await upsertUser({ id: userId, email: body.email, passwordHash });
    const event = createEvent('UserRegistered', { userId, email: body.email }, context.invocationId);
    await publishEvent(config.queues.userRegistered, event);
    logger.info({ eventId: event.eventId, traceId: event.traceId }, 'User registered');
    context.res = { status: 201, body: { userId } };
  } catch (err: any) {
    logger.error({ err }, 'Registration failed');
    context.res = { status: 400, body: { error: err.message || 'Invalid request' } };
  }
};

export default httpTrigger;

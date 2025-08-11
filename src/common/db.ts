import { CosmosClient } from '@azure/cosmos';
import config from './config';

const client = new CosmosClient(config.cosmosConnection);
const database = client.database(config.cosmos.database);

export const usersContainer = database.container(config.cosmos.usersContainer);
export const processedEventsContainer = database.container(config.cosmos.processedContainer);

export async function upsertUser(user: { id: string; email: string; passwordHash: string }) {
  await usersContainer.items.upsert(user);
}

export async function hasProcessed(eventId: string): Promise<boolean> {
  try {
    await processedEventsContainer.item(eventId, eventId).read();
    return true;
  } catch {
    return false;
  }
}

export async function markProcessed(eventId: string): Promise<void> {
  await processedEventsContainer.items.upsert({ id: eventId });
}

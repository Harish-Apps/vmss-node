jest.mock('@azure/cosmos', () => ({
  CosmosClient: jest.fn().mockImplementation(() => ({
    database: () => ({
      container: () => ({
        items: { upsert: jest.fn() },
        item: () => ({ read: jest.fn().mockRejectedValue(new Error('not found')) })
      })
    })
  })),
}));

import { upsertUser, hasProcessed } from '../src/common/db';

describe('db layer', () => {
  it('upserts user without error', async () => {
    await expect(upsertUser({ id: '1', email: 'a', passwordHash: 'b' })).resolves.toBeUndefined();
  });

  it('returns false if event not processed', async () => {
    await expect(hasProcessed('1')).resolves.toBe(false);
  });
});

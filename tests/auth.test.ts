import jwt from 'jsonwebtoken';
import { verifyAuth } from '../src/common/auth';
import config from '../src/common/config';

describe('auth verifier', () => {
  it('verifies valid token', () => {
    const token = jwt.sign({ sub: '123' }, config.jwtSecret, { issuer: config.jwtIssuer });
    const payload = verifyAuth(`Bearer ${token}`);
    expect(payload.sub).toBe('123');
  });

  it('throws on missing token', () => {
    expect(() => verifyAuth(undefined)).toThrow();
  });
});

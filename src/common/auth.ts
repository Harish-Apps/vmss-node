import jwt from 'jsonwebtoken';
import config from './config';

export interface AuthPayload {
  sub: string;
  roles?: string[];
  iss: string;
  iat: number;
  exp: number;
}

export function verifyAuth(authHeader?: string): AuthPayload {
  if (!authHeader) {
    throw new Error('Missing Authorization header');
  }
  const [scheme, token] = authHeader.split(' ');
  if (scheme !== 'Bearer' || !token) {
    throw new Error('Invalid Authorization header');
  }
  try {
    return jwt.verify(token, config.jwtSecret, {
      algorithms: ['HS256'],
      issuer: config.jwtIssuer,
    }) as AuthPayload;
  } catch {
    throw new Error('Unauthorized');
  }
}

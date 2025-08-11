import jwt from 'jsonwebtoken';
import config from '../common/config';

const token = jwt.sign(
  { sub: 'test-user' },
  config.jwtSecret,
  { issuer: config.jwtIssuer, expiresIn: '1h' }
);

console.log(token);

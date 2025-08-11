module.exports = {
  root: true,
  env: { node: true, jest: true },
  parser: '@typescript-eslint/parser',
  parserOptions: { project: './tsconfig.json' },
  plugins: ['@typescript-eslint', 'import'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/typescript',
    'prettier'
  ],
  rules: {
    'import/order': ['error', { 'newlines-between': 'always' }]
  }
};

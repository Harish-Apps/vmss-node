# Event-Driven Azure Functions Demo

This repository contains a sample event-driven application built on **Azure Functions (Node.js 20, TypeScript)**. It demonstrates user registration and welcome email workflow using **Azure Service Bus**, **Cosmos DB**, **Application Insights**, and **Key Vault** secured secrets with simple **JWT authentication**.

## Architecture
```
client --> [HTTP Function /api/register] --> Cosmos DB
       \--> Service Bus queue: user-registered --> [onUserRegistered] --> Service Bus queue: email-send-requested --> [onEmailSendRequested]
```

Sequence:
```
Client -> register -> UserRegistered event -> onUserRegistered -> EmailSendRequested event -> onEmailSendRequested -> EmailSent (log)
```

## Local Development

1. Install dependencies and tools:
   ```bash
   npm install
   ```
2. Copy `local.settings.json.example` to `local.settings.json` and fill in connection strings.
3. Build and start the Functions host:
   ```bash
   npm start
   ```
4. Mint a test JWT:
   ```bash
   npm run token:mint
   ```
5. Send a request using `tests/register.http` (REST Client) or curl.

## Testing

Run lint and unit tests:
```bash
npm test
```

## Deployment

### Infrastructure (Bicep)
Deploy resources to a resource group:
```bash
az deployment group create \
  --resource-group <rg> \
  --template-file infra/bicep/main.bicep \
  --parameters @infra/parameters/dev.json
```

### GitHub Actions
Workflow `ci-cd.yml` builds, tests and deploys the Function App on pushes to `main`. Required secrets:
- `AZURE_CREDENTIALS`
- `RESOURCE_GROUP`
- `FUNCTIONAPP_NAME`
- `SERVICE_BUS_CONNECTION`
- `COSMOS_CONNECTION`
- `JWT_SECRET`
- `APPINSIGHTS_CONNECTION_STRING`
- `KEY_VAULT_NAME` (for reference)

## Troubleshooting
- Ensure Service Bus and Cosmos DB connection strings are valid.
- Use Azure Portal to inspect dead-letter queues for failed messages.
- Check Application Insights logs for detailed traces.

## License
MIT

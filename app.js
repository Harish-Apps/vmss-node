/*
 * Minimal HTTP server for the VMSS sample application.
 *
 * This implementation uses Node.js' built-in 'http' module to avoid
 * external dependencies.  The server listens on the port specified by
 * the PORT environment variable (defaulting to 80) and returns a simple
 * greeting on every request.  Using the core http module eliminates the
 * need to download packages from npm, which makes the deployment more
 * resilient in restricted network environments.
 */
const http = require('http');

const port = process.env.PORT || 80;

const requestListener = (req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from Azure VM Scale Set!');
};

const server = http.createServer(requestListener);

server.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
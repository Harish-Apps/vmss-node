const http = require('http');
const fs = require('fs');
const path = require('path');

const port = process.env.PORT || 80;
const publicDir = path.join(__dirname, 'public');

const server = http.createServer((req, res) => {
  const filePath = path.join(publicDir, req.url === '/' ? 'index.html' : req.url);
  const extname = path.extname(filePath).toLowerCase();
  const contentType = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.css': 'text/css'
  }[extname] || 'text/plain';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

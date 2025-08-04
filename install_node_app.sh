#!/bin/bash

#-------------------------------------------------------------------------------
# install_node_app.sh
#
# This script is designed to be run on a fresh Ubuntu-based virtual machine as
# part of a Virtual Machine Scale Set (VMSS) deployment.  It installs Node.js
# and NPM, writes a simple Express application to disk, installs the
# dependencies, and configures the app to run as a systemd service on port 80.
#
# The script is intended to be invoked by the Azure Custom Script Extension as
# part of a VMSS deployment.  See the accompanying `create_vmss.sh` for an
# example of how to attach this script using the `az vmss extension set`
# command.  When executed via the Custom Script Extension the script runs as
# root, so no sudo prefixes are necessary for package installation or service
# configuration.
#-------------------------------------------------------------------------------

set -euo pipefail

echo "[install_node_app.sh] Installing Node.js and dependencies..."

# Install curl if not present (some images may not include curl by default)
if ! command -v curl >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y curl
fi

# Set up NodeSource repository for the LTS release of Node.js.  The LTS
# distribution is a stable, long-term support version suitable for production.
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -

# Install Node.js and NPM.
apt-get update -y
apt-get install -y nodejs

echo "[install_node_app.sh] Creating application directory..."

# Define the application directory.  We place the app under /opt which is a
# conventional location for optional package software on Linux systems.
APP_DIR="/opt/nodeapp"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

echo "[install_node_app.sh] Writing package.json and application code..."

# Write the package.json for the sample application.  A here-document is used
# to embed JSON directly into the script without worrying about escaping.
cat > package.json <<'PACKAGE_JSON'
{
  "name": "vmss-node-app",
  "version": "1.0.0",
  "description": "Sample Node.js application for Azure VM Scale Set.",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
PACKAGE_JSON

# Write the Express application.  The app listens on PORT (default 80) and
# responds with a friendly greeting.  Using a here-document keeps the file
# self-contained and easy to read.
cat > app.js <<'APP_JS'
const express = require('express');
const app = express();
const port = process.env.PORT || 80;

app.get('/', (req, res) => {
  res.send('Hello from Azure VM Scale Set!');
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
APP_JS

echo "[install_node_app.sh] Skipping npm install as there are no external dependencies."

echo "[install_node_app.sh] Configuring systemd service..."

# Define a systemd service to automatically start the Node.js app on boot and
# restart it if it crashes.  The service runs as the root user and uses port
# 80 by default, which means no additional privileges are required to bind
# the port.  If you wish to run the application under a non-root user, you
# should create that user ahead of time and adjust the User directive below.
cat > /etc/systemd/system/nodeapp.service <<'SERVICE'
[Unit]
Description=Node.js VMSS App
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/nodeapp/app.js
WorkingDirectory=/opt/nodeapp
Restart=always
Environment=PORT=80
User=root

[Install]
WantedBy=multi-user.target
SERVICE

echo "[install_node_app.sh] Enabling and starting the Node.js service..."

systemctl daemon-reload
systemctl enable nodeapp
systemctl restart nodeapp

<<<<<<< HEAD
echo "[install_node_app.sh] Application installed and running."
=======
echo "[install_node_app.sh] Application installed and running."
>>>>>>> 4a64e6d7b14313dc91e252534bfe2014a7f562f1

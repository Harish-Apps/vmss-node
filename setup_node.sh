#!/bin/bash
set -e

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs git

# Create application directory
APP_DIR=/var/www/app
mkdir -p $APP_DIR
chown azureuser:azureuser $APP_DIR

# Create systemd service
cat <<'EOT' > /etc/systemd/system/nodeapp.service
[Unit]
Description=Node.js Application
After=network.target

[Service]
Environment=PORT=80
Type=simple
User=azureuser
WorkingDirectory=/var/www/app
ExecStart=/usr/bin/node /var/www/app/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable nodeapp.service

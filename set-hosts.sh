#!/bin/sh
# get current IP
CURRENT_IP=$(hostname -I | awk '{print $2}')

# Append the entry to /etc/hosts
cat <<EOF >> /etc/hosts
$CURRENT_IP www.test.com
EOF

echo "Added $CURRENT_IP www.test.com to /etc/hosts"

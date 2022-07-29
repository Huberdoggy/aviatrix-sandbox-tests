#!/bin/bash
sudo su - # Switch to root (No passwd by default, won't prompt)
apt update
# when 'S' used with 's', show err if fail, 'L' will redirect location if URL moved
# Pipe to add apt key from stdin
curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>/home/ubuntu/errors | apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" # Will resolve to 'focal'
# Refresh repos again
apt update
apt install -y docker-ce
# Add 'ubuntu' user to Docker group
usermod -aG docker ubuntu

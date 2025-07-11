#!/bin/bash

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && apt-get -yqq upgrade && apt-get -yqq dist-upgrade sudo

USER_NAME=$(getent passwd | awk -F: '$3 == 1000 {print $1}')
if [ -z "$USER_NAME" ]; then
  USER_NAME=adhoc
fi

# fix a locale setting warning from Perl
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Installl common packages
apt-get install -yqq git python3-pip
pip install git-aggregator --break-system-packages

# Installl docker
apt-get install -yqq ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

DETECTED_OS=$(. /etc/os-release && echo "$ID")
# Add the repository to Apt sources:
if [ "$DETECTED_OS" == "ubuntu" ]; then
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
else
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

if [ "$DETECTED_OS" == "debian" ]; then
  if [ -d /usr/sbin ]; then
    # Add /usr/sbin to PATH if it is not already there
    if [[ ":$PATH:" != *":/usr/sbin:"* ]]; then
      export PATH="$PATH:/usr/sbin"
    fi
  fi
fi

apt-get update
apt-get install -yqq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create user and group
groupadd docker || true
useradd -u 1000 -m -s /bin/bash $USER_NAME || true
usermod -aG docker $USER_NAME
# Add user to sudo group
usermod -aG sudo $USER_NAME
# sudo without password
echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Copy ssh public key
mkdir -p /home/$USER_NAME/.ssh
chmod 700 /home/$USER_NAME/.ssh
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh
# Copy ssh public key
if [ ! -f /root/.ssh/authorized_keys ]; then
  echo "No authorized_keys found in /root/.ssh, please add your public key there."
  exit 1
fi
cp /root/.ssh/authorized_keys /home/$USER_NAME/.ssh/authorized_keys
chmod 600 /home/$USER_NAME/.ssh/authorized_keys
chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
# Allow $USER_NAME user to login
echo "AllowUsers $USER_NAME" >> /etc/ssh/sshd_config

# SSH Setup
# Disable password authentication
sed -i -E 's/^\s*#?\s*PasswordAuthentication\s+.*/PasswordAuthentication no/' /etc/ssh/sshd_config
# Disable root login
sed -i -E 's/^\s*#?\s*PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config
# Disable empty passwords
sed -i -E 's/^\s*#?\s*PermitEmptyPasswords\s+.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
# Disable X11 forwarding
sed -i -E 's/^\s*#?\s*PermitX11Forwarding\s+.*/PermitX11Forwarding no/' /etc/ssh/sshd_config
# Disable TCP forwarding
sed -i -E 's/^\s*#?\s*AllowTcpForwarding\s+.*/AllowTcpForwarding no/' /etc/ssh/sshd_config
# Disable agent forwarding
sed -i -E 's/^\s*#?\s*AllowAgentForwarding\s+.*/AllowAgentForwarding no/' /etc/ssh/sshd_config
# Disable DNS lookups
sed -i -E 's/^\s*#?\s*UseDNS\s+.*/UseDNS no/' /etc/ssh/sshd_config
# Disable TCPKeepAlive
sed -i -E 's/^\s*#?\s*TCPKeepAlive\s+.*/TCPKeepAlive no/' /etc/ssh/sshd_config
# Disable GSSAPIAuthentication
sed -i -E 's/^\s*#?\s*GSSAPIAuthentication\s+.*/GSSAPIAuthentication no/' /etc/ssh/sshd_config
# Disable GSSAPIDelegateCredentials
sed -i -E 's/^\s*#?\s*GSSAPIDelegateCredentials\s+.*/GSSAPIDelegateCredentials no/' /etc/ssh/sshd_config
# Alow only SSH protocol 2
sed -i -E 's/^\s*#?\s*Protocol\s+.*/Protocol 2/' /etc/ssh/sshd_config
# Disable SSH v1
sed -i -E 's/^\s*#?\s*HostKey\s+.*/HostKey \/etc\/ssh\/ssh_host_rsa_key/' /etc/ssh/sshd_config

# Delete root password
passwd -l root
ADHOC_HOME="/home/$USER_NAME"

# Fail2Ban
apt-get install -yqq fail2ban rsyslog

# Odoo login
cat > /etc/fail2ban/filter.d/odoo.conf <<EOF
[Definition]
failregex = ^\S+ <HOST> - - \[.*\] "(POST|GET) /web/login.* (200|403|404|503)
ignoreregex =
EOF

cat > /etc/fail2ban/jail.d/odoo.conf <<EOF
[odoo]
enabled = true
filter = odoo
logpath = $ADHOC_HOME/odoo/nginx_logs/access.log
maxretry = 10
findtime = 10m
bantime = 1h
EOF

# Rapid waf
cat > /etc/fail2ban/filter.d/waf.conf <<EOF
[Definition]
failregex = ^\S+ <HOST> - - \[.*\] "(GET|POST) .*(\.php|/wp-).*" (403|404|503)
ignoreregex =
EOF

cat > /etc/fail2ban/jail.d/waf.conf <<EOF
[waf]
enabled = true
filter = waf
logpath = $ADHOC_HOME/odoo/nginx_logs/access.log
maxretry = 3
findtime = 5m
bantime = 1h
EOF

# TODO - Add more filters badbrowsers, etc.
systemctl start fail2ban
systemctl enable fail2ban
fail2ban-client status odoo

mkdir -p $ADHOC_HOME/odoo
mkdir -p $ADHOC_HOME/odoo/odoo/config
mkdir -p $ADHOC_HOME/odoo/odoo/custom-addons
mkdir -p $ADHOC_HOME/odoo/odoo/enterprise
# Create directories for nginx
mkdir -p $ADHOC_HOME/odoo/html
mkdir -p $ADHOC_HOME/odoo/vhost.d
mkdir -p $ADHOC_HOME/odoo/certs
mkdir -p $ADHOC_HOME/odoo/acme.sh
mkdir -p $ADHOC_HOME/odoo/nginx_logs
# Create directories for data
mkdir -p $ADHOC_HOME/odoo/data
mkdir -p $ADHOC_HOME/odoo/data/odoo

# Create .env
cat > $ADHOC_HOME/odoo/.env <<EOF
CLIENT_DOMAIN=$CLIENT_DOMAIN
LE_EMAIL=$LE_EMAIL
EOF

# Download docker-compose.yaml
wget -qO- https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/odoo/V$ODOO_VERSION/Dockerfile > $ADHOC_HOME/odoo/Dockerfile
wget -qO- https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/odoo/V$ODOO_VERSION/docker-compose.yaml > $ADHOC_HOME/odoo/docker-compose.yaml

wget -qO- https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/odoo/V$ODOO_VERSION/nginx.conf > $ADHOC_HOME/odoo/vhost.d/$CLIENT_DOMAIN

wget -qO- https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/odoo/V$ODOO_VERSION/odoo.conf > $ADHOC_HOME/odoo/odoo/config/odoo.conf

ADMIN_PASSWD=$(openssl rand -base64 32 | tr -d '/&\\')
sed -i "s|^admin_passwd *= *.*|admin_passwd = $ADMIN_PASSWD|" "$ADHOC_HOME/odoo/odoo/config/odoo.conf"

if [ -z "$ODOO_ENTERPRISE_TOKEN" ]; then
  echo "ODOO_ENTERPRISE_TOKEN is not set, skipping enterprise addons setup."
else
  git clone https://$ODOO_ENTERPRISE_TOKEN@github.com/adhoc-cicd/odoo-enterprise.git $ADHOC_HOME/odoo/odoo/enterprise --branch ${ODOO_VERSION} --single-branch
  if [ $? -ne 0 ]; then
    echo "Failed to clone Odoo Enterprise addons from adhoc-cicd repository. Please check your ODOO_ENTERPRISE_TOKEN or the repository URL."
    exit 1
  fi
fi

# Clone Odoo custom addons
git config --global user.name "Adhoc External"
git config --global user.email $LE_EMAIL

wget -qO- https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/odoo/V$ODOO_VERSION/gitaggregate.yaml > $ADHOC_HOME/odoo/gitaggregate.yaml
cd $ADHOC_HOME/odoo/odoo/custom-addons
gitaggregate --jobs $(nproc) -f -c $ADHOC_HOME/odoo/gitaggregate.yaml --expand-env aggregate
cd -

if ! awk "BEGIN {exit ($ODOO_VERSION >= 16.0)}"; then
  ADDONS_PATHS=$(ls $ADHOC_HOME/odoo/odoo/custom-addons | sed "s|^|/mnt/extra-addons/|" | paste -sd,)",/mnt/enterprise-addons"
  sed -i "s|^addons_path *= *.*|addons_path = $ADDONS_PATHS|" $ADHOC_HOME/odoo/odoo/config/odoo.conf
fi

# Fix permissions
chown -R $USER_NAME:$USER_NAME $ADHOC_HOME/odoo

# Start Odoo
su $USER_NAME -c "cd ~/odoo && docker compose up -d"

echo "Odoo setup completed successfully."
echo "You can access Odoo at https://$CLIENT_DOMAIN"
echo "Admin password is: $ADMIN_PASSWD"

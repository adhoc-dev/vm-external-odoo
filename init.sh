#!/bin/bash

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update && apt-get -yqq upgrade && apt-get -yqq dist-upgrade

# Installl common packages
apt-get install -yqq git python3-pip
pip install git-aggregator

# Installl docker
apt-get install -yqq ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -yqq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create user and group
groupadd docker | true
useradd -u 1000 -m -s /bin/bash adhoc
usermod -aG docker adhoc
# Add user to sudo group
usermod -aG sudo adhoc
# sudo without password
echo "adhoc ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Copy ssh public key
mkdir -p /home/adhoc/.ssh
chmod 700 /home/adhoc/.ssh
chown -R adhoc:adhoc /home/adhoc/.ssh
# Copy ssh public key
cp /root/.ssh/authorized_keys /home/adhoc/.ssh/authorized_keys
chmod 600 /home/adhoc/.ssh/authorized_keys
chown adhoc:adhoc /home/adhoc/.ssh/authorized_keys
# Allow adhoc user to login
echo "AllowUsers adhoc" >> /etc/ssh/sshd_config

# SSH Setup
# Disable password authentication
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Disable root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
# Disable empty passwords
sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/' /etc/ssh/sshd_config
# Disable X11 forwarding
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
# Disable TCP forwarding
sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
# Disable agent forwarding
sed -i 's/AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config
# Disable DNS lookups
sed -i 's/#UseDNS no/UseDNS no/' /etc/ssh/sshd_config
# Disable TCPKeepAlive
sed -i 's/#TCPKeepAlive yes/TCPKeepAlive no/' /etc/ssh/sshd_config
# Disable GSSAPIAuthentication
sed -i 's/#GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
# Disable GSSAPIDelegateCredentials
sed -i 's/#GSSAPIDelegateCredentials yes/GSSAPIDelegateCredentials no/' /etc/ssh/sshd_config
# Alow only SSH protocol 2
sed -i 's/#Protocol 2/Protocol 2/' /etc/ssh/sshd_config
# Disable SSH v1
sed -i 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/' /etc/ssh/sshd_config

# Delete root password
passwd -l root
ADHOC_HOME="/home/adhoc"

# Fail2Ban
apt-get install -yqq fail2ban

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

if awk "BEGIN {exit !($ODOO_VERSION >= 16.0)}"; then
  ADDONS_PATHS=$(ls $ADHOC_HOME/odoo/odoo/custom-addons | sed "s|^|/mnt/extra-addons/|" | paste -sd,)",/mnt/enterprise-addons"
  sed -i "s|^addons_path *= *.*|addons_path = $ADDONS_PATHS|" $ADHOC_HOME/odoo/odoo/config/odoo.conf
fi

# Fix permissions
chown -R adhoc:adhoc $ADHOC_HOME/odoo

# Start Odoo
su adhoc -c "cd ~/odoo && docker compose up -d"

echo "Odoo setup completed successfully."
echo "You can access Odoo at https://$CLIENT_DOMAIN"
echo "Admin password is: $ADMIN_PASSWD"

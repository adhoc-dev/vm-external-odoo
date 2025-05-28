# Adhoc Open Odoo Installer

This repository contains minimal scripts in order to install odoo in your own server.

## How to install

### Base system / requirements

Prepare a VM with ubuntu 22.04 LTS (and access as root) with static public IP
Chose a domain name and configure this domain to the public IP

### As root run

```sh
export CLIENT_DOMAIN="external-odoo.example.com"
export LE_EMAIL="admin@example.com"
export ODOO_VERSION=18.0
wget -qO- https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/init.sh | bash -c
```

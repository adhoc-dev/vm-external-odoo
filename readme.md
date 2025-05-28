# Adhoc Open Odoo Installer

This repository contains minimal scripts in order to install odoo in your own server.

## How to install

### Base system / requirements

Prepare a VM with ubuntu 22.04 LTS (and access as root) with static public IP
Chose a domain name and configure this domain to point to the public IP

### As root run

```sh
export CLIENT_DOMAIN="external-odoo.example.com"
export LE_EMAIL="admin@example.com"
export ODOO_VERSION=18.0
bash -c "$(curl -fsSL https://raw.githubusercontent.com/adhoc-dev/vm-external-odoo/refs/heads/main/init.sh)"
```

Now you can configure your database or restore an old one

After that as adhoc user you must disable the database selector and you can set se default databse if you need it

```sh
# Disable database selector
sed -i "s|^list_db *= *.*|admin_passwd = False|" "~/odoo/odoo/config/odoo.conf"
# Set default database (where odoo is the database name o this example)
sed -i "s|^# db_name = odoo|db_name = odoo|" "~/odoo/odoo/config/odoo.conf"

cd ~/odoo && docker restart odoo
```

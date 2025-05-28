from odoo:14.0

# Install additional dependencies
USER root
RUN apt-get -qq update \
    && echo "root:odoo" | chpasswd \
    && echo "odoo:odoo" | chpasswd \
    && apt-get install -y \
    # Common dependencies
    git \
    ssh-client \
    # Build tools
    build-essential \
    libfreetype6-dev \
    libfribidi-dev \
    libghc-zlib-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    liblcms2-dev \
    libldap2-dev \
    libopenjp2-7-dev \
    # libpq-dev \
    libsasl2-dev \
    libtiff5-dev \
    libwebp-dev \
    tcl-dev \
    tk-dev \
    zlib1g-dev \
    ca-certificates \
    libcups2-dev \
    libcurl4-openssl-dev \
    parallel \
    python3-dev \
    libevent-dev \
    libjpeg-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    swig \
    # install rsync for odoo upgrade scripts
    rsync \
    # para ayudar en debugging (no requerido)
    iputils-ping \
    # required by pip install git+https sources
    wget \
    gnupg2 \
    # required by upgrade
    rsync \
    # required by upgrade
    openssh-client \
    # Temp
    nano \
    && rm -rf /var/lib/apt/lists/*

USER odoo
# Install Python packages
RUN pip3 install --no-cache-dir --user --no-warn-script-location \
        git-aggregator==2.1.0 \
        ipython==7.34.0 \
        pysnooper==1.1.1 \
        ipdb==0.13.9 \
        git+https://github.com/OCA/openupgradelib.git \
        click-odoo-contrib==1.16.1 \
        pg-activity==3.0.1 \
        phonenumbers==8.12.57 \
        # pyOpenSSL==22.1.0 \
        # cryptography==38.0.4 \
        redis==2.10.5 \
        Odooly==2.1.9 \
        git-aggregator==2.1.0 \
        dnspython3==1.15.0 \
        google-cloud-storage==2.7.0 \
        git+https://github.com/rancher/client-python.git@master \
        boto3==1.9.102 \
        html2text==2020.1.16 \
        python-stdnum==1.17 \
        httplib2==0.20.4 \
        git+https://github.com/pysimplesoap/pysimplesoap@a330d9c4af1b007fe1436f979ff0b9f66613136e \
        git+https://github.com/ingadhoc/pyafipws@py3k \
        genshi==0.7.7 \
        git+https://github.com/adhoc-dev/aeroolib@master-fix-ods \
        git+https://github.com/aeroo/currency2text.git \
        pycups==2.0.1 \
        algoliasearch==2.6.2 \
        email-validator==1.1.1 \
        unrar==0.4 \
        mercadopago==2.2.0 \
        reportlab==3.5.55 \
        ShopifyApi==8.0.0 \
        geoip2==4.6.0 \
        pdf417gen==0.7.1

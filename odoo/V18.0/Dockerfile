from odoo:18.0

# Install additional dependencies
USER root
RUN apt-get -qq update \
    && echo "root:odoo" | chpasswd \
    && echo "odoo:odoo" | chpasswd \
    && apt-get install -yqq --no-install-recommends \
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
    libsasl2-dev \
    libtiff5-dev \
    libwebp-dev \
    tcl-dev \
    tk-dev \
    zlib1g-dev \
    # PyCurl
    libcurl4-openssl-dev \
    libssl-dev \
    # PyCups
    libcups2-dev \
    # QR en PDF
    pkg-config \
    libcairo2-dev \
    # required by pip install git+https sources
    wget \
    gnupg2 \
    # required by upgrade
    rsync \
    # required by upgrade
    openssh-client \
    # Temp
    nano \
    # QR en PDF
    libcairo2 \
    # Python dependencies
    python3-nltk \
    python3-redis \
    python3-googleapi \
    python3-github \
    python3-cups \
    rar \
    && rm -rf /var/lib/apt/lists/*

USER odoo
# Install Python packages
RUN pip3 install --no-cache-dir --break-system-packages --user --no-warn-script-location \
        git-aggregator==4.0.2 \
        firebase-admin==6.6.0 \
        transifex-python \
        google-cloud-storage==2.19.0 \
        google-cloud-compute==1.25.0 \
        git+https://github.com/rancher/client-python.git@master \
        boto3==1.36.2 \
        psycopg2-binary \
        html2text==2024.2.26 \
        httplib2==0.22.0 \
        git+https://github.com/ingadhoc/pyafipws.git@odoo18 \
        genshi==0.7.9 \
        git+https://github.com/adhoc-dev/aeroolib@master-fix-ods \
        git+https://github.com/aeroo/currency2text.git \
        Markdown==3.7 \
        sentry-sdk==2.20.0 \
        odoo-test-helper==2.1.1 \
        algoliasearch==2.6.2 \
        email-validator==2.2.0 \
        unrar==0.4 \
        mercadopago==2.2.3 \
        geoip2==4.8.1 \
        pdf417gen==0.8.0 \
        ShopifyApi==12.7.0 \
        pandas==2.2.3 \
        openpyxl==3.1.5 \
        websocket-client==1.8.0 \
        scikit-learn==1.6.1 \
        python-json-logger \
        pycryptodome==3.21.0 \
        rlpycairo \
        ipdb \
        pg-activity

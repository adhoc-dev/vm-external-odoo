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
    libcups2-dev \
    libcurl4-openssl-dev \
    python3-dev \
    libevent-dev \
    libjpeg-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    swig \
    parallel \
    ca-certificates \
    # required by pip install git+https sources
    wget \
    gnupg2 \
    # install rsync for odoo upgrade scripts
    rsync \
    # para ayudar en debugging (no requerido)
    iputils-ping \
    rar \
    && rm -rf /var/lib/apt/lists/*

USER odoo
# Install Python packages
RUN pip3 install --no-cache-dir --break-system-packages --user --no-warn-script-location \
    nltk==3.8.1 \
    redis==5.2.1 \
    google-api-python-client==2.157.0 \
    PyGithub==1.57 \
    git-aggregator==2.1.0 \
    firebase-admin==6.0.1 \
    transifex-python==3.0.3 \
    dnspython3==1.15.0 \
    google-cloud-storage==2.6.0 \
    git+https://github.com/rancher/client-python.git@master \
    boto3==1.26.7 \
    psycopg2-binary \
    html2text==2020.1.16 \
    httplib2==0.20.4 \
    git+https://github.com/pysimplesoap/pysimplesoap@a330d9c4af1b007fe1436f979ff0b9f66613136e \
    git+https://github.com/ingadhoc/pyafipws@py3k \
    genshi==0.7.7 \
    git+https://github.com/adhoc-dev/aeroolib@master-fix-ods \
    git+https://github.com/aeroo/currency2text.git \
    Markdown==3.4.1 \
    sentry-sdk==1.9.0 \
    pycups==2.0.1 \
    odoo-test-helper==2.0.2 \
    algoliasearch==2.6.2 \
    pycurl==7.45.1 \
    email-validator==1.3.0 \
    unrar==0.4 \
    mercadopago==2.2.0 \
    geoip2==4.6.0 \
    pdf417gen==0.7.1 \
    ShopifyApi==12.3.0 \
    pandas==2.1.2 \
    openpyxl==3.1.2 \
    websocket-client==1.8.0 \
    kubernetes==31.0.0 \
    scikit-learn==1.5.2 \
    python-json-logger==3.2.1
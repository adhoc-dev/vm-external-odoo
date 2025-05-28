from odoo:15.0

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
    libpq-dev \
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
RUN pip3 install --no-cache-dir --break-system-packages --user --no-warn-script-location \
        git-aggregator==2.1.0 \
        ipython==8.7.0 \
        pdfminer.six==20220319 \
        pysnooper==1.1.1 \
        ipdb==0.13.9 \
        # Gestión de paquetes pip desde odoo project (#42696)
        git+https://github.com/OCA/openupgradelib.git@73f7b8fda0f5102f7bd58df831b39e4e1c5a180c \
        click-odoo-contrib==1.16.1 \
        pg-activity==3.0.1 \
        phonenumbers==8.13.1 \
        pyOpenSSL==19.0.0 \
        cryptography==35.0.0 \
        ## cloud platform, odoo y odoo saas
        redis==2.10.5 \
        google-api-python-client==2.66.0 \
        # Gestión de paquetes pip desde odoo project (#42696)
        # Odooly==2.1.9 \
        PyGithub==1.57 \
        git-aggregator==2.1.0 \
        # TODO revisar si sigue siendo necesario
        firebase-admin==6.0.1 \
        transifex-python==3.0.3 \
        dnspython3==1.15.0 \
        google-cloud-storage==2.6.0 \
        git+https://github.com/rancher/client-python.git@master \
        boto3==1.9.102 \
        # for pg_activity
        psycopg2-binary \
        ## ingadhoc/website
        html2text==2020.1.16 \
        ## ingadhoc/odoo-uruguay
        python-stdnum>=1.16 \
        ## ingadhoc/odoo-argentina
        # forzamos version httplib2==0.20.4 porque con lanzamiento de 0.21 (https://pypi.org/project/httplib2/#history) empezo a dar error de ticket 56946
        httplib2==0.20.4 \
        git+https://github.com/pysimplesoap/pysimplesoap@a330d9c4af1b007fe1436f979ff0b9f66613136e \
        git+https://github.com/ingadhoc/pyafipws@py3k \
        ## ingadhoc/aeroo
        # use this genshi version to fix error when, for eg, you send arguments like "date=True" check this  \https://genshi.edgewall.org/ticket/600
        genshi==0.7.7 \
        git+https://github.com/adhoc-dev/aeroolib@master-fix-ods \
        git+https://github.com/aeroo/currency2text.git \
        # mergebot requirements
        Markdown==3.4.1 \
        sentry-sdk==1.9.0 \
        # requirement de base_report_to_printer
        pycups==2.0.1 \
        # varios
        algoliasearch==2.6.2 \
        pycurl==7.45.1 \
        email-validator==1.3.0 \
        unrar==0.4 \
        mercadopago==2.2.0 \
        # Fix xlrd con lógica de odoo (sistemas-contabilidad)
        xlrd==1.2.0 \
        # external dependency for mail_autosubscribe (también necesaria para ejecutar casos de test)
        odoo_test_helper==2.0.2 \
        # geoip
        geoip2==4.6.0 \
        # l10n_cl_edi y probablemente otros (la version la tomamos de runbot data)
        pdf417gen==0.7.1

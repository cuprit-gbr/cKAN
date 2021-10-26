FROM alpine:3.7

# Internal environment variables
ENV APP_DIR=/srv/app
ENV SRC_DIR=/srv/app/src
ENV CKAN_INI=${APP_DIR}/ckan.ini
ENV PIP_SRC=${SRC_DIR}
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV GIT_URL=https://github.com/ckan/ckan.git
# CKAN version to build
ENV GIT_BRANCH=ckan-2.9.3

WORKDIR ${APP_DIR}

# Set up environment variables
ENV APP_DIR=/srv/app
ENV TZ=UTC
RUN echo ${TZ} > /etc/timezone

# Install necessary packages to run CKAN
RUN apk add --no-cache tzdata \
        git \
        gettext \
        postgresql-client \
        python3 \
        apache2-utils \
        libxml2 \
        libxslt \
        musl-dev \
        uwsgi-http \
        uwsgi-corerouter \
        uwsgi-python3 \
        py3-gevent \
        uwsgi-gevent \
        libmagic \
        curl \
        sudo && \
    # Packages to build CKAN requirements and plugins
    apk add --no-cache --virtual .build-deps \
        postgresql-dev \
        gcc \
        make \
        g++ \
        autoconf \
        automake \
	      libtool \
	      openldap-dev \
        python3-dev \
        py3-virtualenv \
        libxml2-dev \
        libxslt-dev \
        linux-headers && \
    # Create SRC_DIR
    mkdir -p ${SRC_DIR} && \
    # Install pip
    curl -o ${SRC_DIR}/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python3 ${SRC_DIR}/get-pip.py 'pip==20.3.3' && \
    rm -rf ${SRC_DIR}/get-pip.py

# Set up Python3 virtual environment
RUN cd ${APP_DIR} && \
    python3 -m venv ${APP_DIR} && \
    source ${APP_DIR}/bin/activate

# Virtual environment binaries/scripts to be used first
ENV PATH=${APP_DIR}/bin:${PATH}

# Install CKAN and uwsgi
RUN pip3 install --upgrade pip && \
    pip3 install -e git+${GIT_URL}@${GIT_BRANCH}#egg=ckan && \
    pip3 install uwsgi && \
    cd ${SRC_DIR}/ckan && \
    cp who.ini ${APP_DIR} && \
    pip3 install --no-binary :all: -r requirements.txt && \
    # Install CKAN extensions
    pip3 install -e git+https://github.com/okfn/ckanext-envvars.git#egg=ckanext-envvars && \
    pip3 install -e git+https://github.com/cuprit-gbr/ckanext-cuprit#egg=ckanext-cuprit && \
    pip3 install -e git+https://github.com/NaturalHistoryMuseum/ckanext-ldap#egg=ckanext-ldap && \
    pip3 install -e git+https://github.com/ckan/ckanext-dcat.git#egg=ckanext-dcat && \
    pip3 install -r ${SRC_DIR}/ckanext-dcat/requirements.txt && \
    pip3 install -e git+https://github.com/cuprit-gbr/ckanext-resource-type-validation.git#egg=ckanext-resource-type-validation && \
    # Create and update CKAN config
    ckan generate config ${CKAN_INI}

# Install and configure supervisor
RUN pip3 install supervisor && \
mkdir /etc/supervisord.d

# Copy all setup files
COPY setup ${APP_DIR}
COPY setup/supervisor.worker.conf /etc/supervisord.d/worker.conf
COPY setup/supervisord.conf /etc/supervisord.conf

# Create a local user and group to run the app
RUN addgroup -g 92 -S ckan && \
    adduser -u 92 -h /srv/app -H -D -S -G ckan ckan

# Create local storage folder
RUN mkdir -p $CKAN_STORAGE_PATH
RUN chown -R ckan:ckan $CKAN_STORAGE_PATH

# Create entrypoint directory for children image scripts
ONBUILD RUN mkdir /docker-entrypoint.d

RUN chown -R ckan:ckan ${APP_DIR}
RUN chmod u+x /srv/app/start_ckan.sh

# helper script to wait for database
COPY wait-for-databases.sh /usr/bin/wait-for-databases
RUN chmod +x /usr/bin/wait-for-databases

# Patch CKAN https://github.com/ckan/ckan/issues/4576
# check and maybe remove with next version!
COPY patches/. ${SRC_DIR}/ckan
RUN cd ${SRC_DIR}/ckan && git apply -v flask_app.patch && git apply patch_system_info.patch && cd -

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=5s --retries=5 CMD curl --fail http://localhost:5000/api/3/action/status_show || exit 1

CMD ["/srv/app/start_ckan.sh"]

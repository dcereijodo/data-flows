FROM openjdk:8-alpine

# SYSTEM DEPENDENCIES

RUN apk add --update --no-cache \
    git \
    jq \
    wget \
    unzip \
    gettext \
    gcc \
    libc-dev \
    musl-dev \
    postgresql-dev \
    python3-dev \
    py-pip \
    bash \
&& apk add --no-cache openjdk8 \
&& pip3 install --upgrade pip setuptools

# CUSTOM UTILS
#
# It would be ideal to extract this utils into their own container and invoke
# the container from the dags (using ECSOperator for example)

# I could only make it work for now if I install the util as root
RUN git clone https://github.com/dcereijodo/target-s3.git && pip3 install -e target-s3

RUN addgroup -S flows && adduser -S flows -G flows

RUN chmod -R u=rwX,go=rX /usr/local/bin \
  && chown -R flows: /usr/local/bin

USER flows

RUN \
  cd /home/flows/ \
  && wget https://github.com/dcereijodo/tap-s3-json/releases/download/v0.0.2/tap-s3-json-0.0.2.zip \
  && unzip tap-s3-json-0.0.2.zip && chmod +x tap-s3-json-0.0.2/bin/tap-s3-json \
  && ln -s $HOME/tap-s3-json-0.0.2/bin/tap-s3-json /usr/local/bin/tap-s3-json \
  && wget https://github.com/digitalorigin/batch-http/releases/download/v0.1.3/batch-http-0.1.3.zip \
  && unzip batch-http-0.1.3.zip && chmod +x batch-http-0.1.3/bin/batch-http \
  && ln -s $HOME/batch-http-0.1.3/bin/batch-http /usr/local/bin/batch-http

# copy scripts
COPY --chown=flows . /home/flows/
RUN ls -la /home/flows/

ENTRYPOINT ["/home/flows/entrypoint.sh"]

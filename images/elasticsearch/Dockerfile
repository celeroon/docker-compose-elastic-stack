# Use the official Elasticsearch image as the base image
ARG STACK_VERSION
ARG CERT_PASS
FROM docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}

USER root

# Set environment variable to prevent tzdata prompt during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package repositories and install default-jre and ca-certificates-java
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        default-jre \
        ca-certificates-java \
    && rm -rf /var/lib/apt/lists/*

RUN echo ${CERT_PASS} | keytool -importkeystore \
    -destkeystore config/certs/es01/es01.p12 \
    -srckeystore config/certs/elastic-stack-ca.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass ${CERT_PASS} \
    -deststorepass ${CERT_PASS} \
    -noprompt  
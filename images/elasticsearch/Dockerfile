# Use the official Elasticsearch image as the base image
ARG STACK_VERSION
ARG CERT_PASS
FROM docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}

USER root

RUN /usr/share/elasticsearch/jdk/bin/keytool -importkeystore \
    -destkeystore config/certs/es01/es01.p12 \
    -srckeystore config/certs/elastic-stack-ca.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass ${CERT_PASS} \
    -deststorepass ${CERT_PASS} \
    -noprompt
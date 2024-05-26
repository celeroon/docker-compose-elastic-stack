#!/bin/bash

# Path to the flag directory
FLAG_DIR="/usr/share/elasticsearch/flags"

# Ensure the flag directory exists
mkdir -p "$FLAG_DIR"

# Flag files for each keystore operation
FLAG_FILE_CERT_COPIED="$FLAG_DIR/cert_copied"
FLAG_FILE_TRANSPORT_KEYSTORE="$FLAG_DIR/transport_keystore_password_added"
FLAG_FILE_TRANSPORT_TRUSTSTORE="$FLAG_DIR/transport_truststore_password_added"
FLAG_FILE_HTTP_KEYSTORE="$FLAG_DIR/http_keystore_password_added"

# Copy elasticsearch-ca.pem to /certs if not already done
if [ ! -f "$FLAG_FILE_CERT_COPIED" ]; then
    echo "Copy elasticsearch-ca.pem to host's /certs"
    cp /usr/share/elasticsearch/config/certs/elasticsearch-ca.pem /certs/
    touch "$FLAG_FILE_CERT_COPIED"
fi

# Add password to keystore for transport.ssl.keystore.secure_password if not already done
if [ ! -f "$FLAG_FILE_TRANSPORT_KEYSTORE" ]; then
    echo -e "${CERT_PASS}\n" | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password -f > /dev/null 2>&1
    touch "$FLAG_FILE_TRANSPORT_KEYSTORE"
fi

# Add password to keystore for transport.ssl.truststore.secure_password if not already done
if [ ! -f "$FLAG_FILE_TRANSPORT_TRUSTSTORE" ]; then
    echo -e "${CERT_PASS}\n" | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password -f > /dev/null 2>&1
    touch "$FLAG_FILE_TRANSPORT_TRUSTSTORE"
fi

# Add password to keystore for http.ssl.keystore.secure_password if not already done
if [ ! -f "$FLAG_FILE_HTTP_KEYSTORE" ]; then
    echo -e "${CERT_PASS}\n" | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password -f > /dev/null 2>&1
    touch "$FLAG_FILE_HTTP_KEYSTORE"
fi

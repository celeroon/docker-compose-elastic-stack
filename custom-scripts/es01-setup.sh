#!/bin/bash

# Add password to keystore for transport.ssl.keystore.secure_password
echo -e "${CERT_PASS}\n" | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password -f > /dev/null 2>&1

# Add password to keystore for transport.ssl.truststore.secure_password
echo -e "${CERT_PASS}\n" | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password -f > /dev/null 2>&1

# Add password to keystore for http.ssl.keystore.secure_password
echo -e "${CERT_PASS}\n" | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password -f > /dev/null 2>&1

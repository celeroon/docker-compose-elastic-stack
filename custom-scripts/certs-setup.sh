#!/bin/bash

if [ x${CERT_PASS} == x ]; then
    echo "Set the CERT_PASS environment variable in the .env file"
    exit 1
fi

if [ x${ES_SERVER_HOST} == x ]; then
    echo "Set the ES_SERVER_HOST environment variable in the .env file (use the provided script or submit it manually)"
    exit 1
fi

if [ x${FLEET_SERVER_HOST} == x ]; then
    echo "Set the FLEET_SERVER_HOST environment variable in the .env file (use the provided script or submit it manually)"
    exit 1
fi

# Path to the flag directory
FLAG_DIR="/usr/share/elasticsearch/flags"

# Ensure the flag directory exists
mkdir -p "$FLAG_DIR"

# Flag files for each operation
FLAG_FILE_CERTS_DIR="$FLAG_DIR/certs_dir_created"
FLAG_FILE_CA_CERT="$FLAG_DIR/ca_cert_created"
FLAG_FILE_TRANSPORT_CERT="$FLAG_DIR/transport_cert_created"

if [ ! -f "$FLAG_FILE_CERTS_DIR" ]; then
    echo "Creating config/certs directory"
    mkdir -p config/certs
    touch "$FLAG_FILE_CERTS_DIR"
fi

if [ ! -f "$FLAG_FILE_CA_CERT" ]; then
    echo "Creating CA (elastic-stack-ca.p12)"
    bin/elasticsearch-certutil ca -out config/certs/elastic-stack-ca.p12 --pass ${CERT_PASS} -s
    touch "$FLAG_FILE_CA_CERT"
fi

if [ ! -f "$FLAG_FILE_TRANSPORT_CERT" ]; then
    echo "Creating certificate for transport layer (elastic-certificates.p12)"
    bin/elasticsearch-certutil cert --ca config/certs/elastic-stack-ca.p12 -s -out config/certs/elastic-certificates.p12 --ca-pass ${CERT_PASS} --pass ${CERT_PASS}
    touch "$FLAG_FILE_TRANSPORT_CERT"
fi

# Function to check if the input is an IP address
is_ip_address() {
    local ip="$1"
    local IFS='.'
    read -r -a ip_parts <<< "$ip"
    if [[ ${#ip_parts[@]} -ne 4 ]]; then
        return 1  # Not a valid IP address
    fi
    for part in "${ip_parts[@]}"; do
        if ! [[ "$part" =~ ^[0-9]+$ ]] || ((part > 255)); then
            return 1  # Not a valid IP address
        fi
    done
    return 0  # It's an IP address
}

# Function to check if the input is a FQDN
is_fqdn() {
    local fqdn="$1"
    if [[ $fqdn =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0  # It's a FQDN
    else
        return 1  # It's not a FQDN
    fi
}

# Extract ES_SERVER_HOST and FLEET_SERVER_HOST from environment variables
es_server_host="$ES_SERVER_HOST"
fleet_server_host="$FLEET_SERVER_HOST"

# Verify if the inputs are valid IP addresses or FQDNs
if is_ip_address "$es_server_host"; then
    es_ip="      - ${es_server_host}"
    es_dns=""
elif is_fqdn "$es_server_host"; then
    es_ip=""
    es_dns="      - ${es_server_host}"
else
    echo "ES_SERVER_HOST is neither a valid IP address nor a valid Fully Qualified Domain Name."
    exit 1
fi

if is_ip_address "$fleet_server_host"; then
    fleet_ip="      - ${fleet_server_host}"
    fleet_dns=""
elif is_fqdn "$fleet_server_host"; then
    fleet_ip=""
    fleet_dns="      - ${fleet_server_host}"
else
    echo "FLEET_SERVER_HOST is neither a valid IP address nor a valid Fully Qualified Domain Name."
    exit 1
fi

# Flag file for certificates creation
FLAG_FILE_CERTS="$FLAG_DIR/certs_created"

if [ ! -f "$FLAG_FILE_CERTS" ]; then
    echo "Creating certificates for each cluster node"

    # Generate instances.yml content
    instances_yml="instances:\n"
    instances_yml+="  - name: es01\n"
    instances_yml+="    dns:\n"
    instances_yml+="      - es01\n"
    instances_yml+="      - localhost\n"
    instances_yml+="${es_dns}\n"
    instances_yml+="    ip:\n"
    instances_yml+="      - 127.0.0.1\n"
    instances_yml+="      - 127.0.1.1\n"
    instances_yml+="${es_ip}\n"
    instances_yml+="  - name: kibana\n" \
    instances_yml+="    dns:\n" \
    instances_yml+="      - kibana\n" \
    instances_yml+="      - localhost\n" \
    instances_yml+="    ip:\n" \
    instances_yml+="      - 127.0.0.1\n" \
    instances_yml+="      - 127.0.1.1\n" \
    instances_yml+="  - name: fleet-server\n"
    instances_yml+="    dns:\n"
    instances_yml+="      - fleet-server\n"
    instances_yml+="      - localhost\n"
    instances_yml+="${fleet_dns}\n"
    instances_yml+="    ip:\n"
    instances_yml+="      - 127.0.0.1\n"
    instances_yml+="      - 127.0.1.1\n"
    instances_yml+="${fleet_ip}\n"
    instances_yml+="  - name: fleet-server-setup\n" \
    instances_yml+="    dns:\n" \
    instances_yml+="      - fleet-server-setup\n" \
    instances_yml+="      - localhost\n" \
    instances_yml+="    ip:\n" \
    instances_yml+="      - 127.0.0.1\n" \
    instances_yml+="      - 127.0.1.1\n" \
    instances_yml+="  - name: logstash\n" \
    instances_yml+="    dns:\n" \
    instances_yml+="      - logstash\n" \
    instances_yml+="      - localhost\n" \
    instances_yml+="    ip:\n" \
    instances_yml+="      - 127.0.0.1\n" \
    instances_yml+="      - 127.0.1.1\n" \

    # Write instances.yml content to file
    echo -e "$instances_yml" >config/certs/instances.yml
    bin/elasticsearch-certutil cert --silent -out config/certs/certs.zip --in config/certs/instances.yml --ca config/certs/elastic-stack-ca.p12 --pass ${CERT_PASS} --ca-pass ${CERT_PASS}
    unzip -q config/certs/certs.zip -d config/certs
    echo "Converting p12 to pem format"
    openssl pkcs12 -in config/certs/kibana/kibana.p12 -nocerts -out config/certs/kibana/kibana.key -nodes -passin pass:${CERT_PASS}
    openssl pkcs12 -in config/certs/kibana/kibana.p12 -clcerts -nokeys -out config/certs/kibana/kibana.crt -passin pass:${CERT_PASS}
    openssl pkcs12 -in config/certs/fleet-server/fleet-server.p12 -nocerts -out config/certs/fleet-server/fleet-server.key -nodes -passin pass:${CERT_PASS}
    openssl pkcs12 -in config/certs/fleet-server/fleet-server.p12 -clcerts -nokeys -out config/certs/fleet-server/fleet-server.crt -passin pass:${CERT_PASS}
    touch "$FLAG_FILE_CERTS"
fi

# Flag file
FLAG_FILE_CA_PEM="$FLAG_DIR/ca_pem_created"

if [ ! -f "$FLAG_FILE_CA_PEM" ]; then
    if [ ! -f "config/certs/elasticsearch-ca.pem" ]; then
        echo "Generating elasticsearch-ca.pem"
        openssl pkcs12 -in "config/certs/elastic-stack-ca.p12" -clcerts -nokeys -passin pass:${CERT_PASS} \
        | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > "config/certs/elasticsearch-ca.pem"
    fi
    # Create the flag file to indicate that elasticsearch-ca.pem has been created
    touch "$FLAG_FILE_CA_PEM"
fi

# Flag file
FLAG_FILE_PERMISSIONS="$FLAG_DIR/permissions_set"

if [ ! -f "$FLAG_FILE_PERMISSIONS" ]; then
    echo "Setting file permissions"
    chown -R root:root config/certs
    find . -type d -exec chmod 750 \{\} \;
    find . -type f -exec chmod 640 \{\} \;

    # Create the flag file to indicate that permissions have been set
    touch "$FLAG_FILE_PERMISSIONS"
fi

echo "Waiting for Elasticsearch availability"
until curl -s --cacert config/certs/elasticsearch-ca.pem https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done
echo "All done!"
#!/bin/bash

# Path to the flag directory
FLAG_DIR="/usr/share/kibana/flags"

# Ensure the flag directory exists
mkdir -p "$FLAG_DIR"

# Flag files for each operation
FLAG_FILE_KEYSTORE_CREATED="$FLAG_DIR/kibana_keystore_created"
FLAG_FILE_TOKEN_GENERATED="$FLAG_DIR/kibana_token_generated"
FLAG_FILE_TOKEN_STORED="$FLAG_DIR/kibana_token_stored"

# Create the Kibana keystore if not already done
if [ ! -f "$FLAG_FILE_KEYSTORE_CREATED" ]; then
    echo "Creating the Kibana keystore"
    bin/kibana-keystore create
    touch "$FLAG_FILE_KEYSTORE_CREATED"
fi

# Make API request to generate Kibana token if not already done
if [ ! -f "$FLAG_FILE_TOKEN_GENERATED" ]; then
  echo "Making API request to generate Kibana token"
  response=$(curl -s -X POST --cacert config/certs/elasticsearch-ca.pem -u elastic:${ELASTIC_PASSWORD} https://es01:9200/_security/service/elastic/kibana/credential/token/kibana_token)
  touch "$FLAG_FILE_TOKEN_GENERATED"
fi

# Extract the token value from the JSON response and store it securely using kibana-keystore if not already done
if [ ! -f "$FLAG_FILE_TOKEN_STORED" ]; then
  echo "Extracting the token value from the JSON response using grep and awk"
  token_value=$(echo "$response" | grep -o '"value":"[^"]*' | awk -F ':"' '{print $2}')

  echo "Storing the token value securely using kibana-keystore"
  echo -n "$token_value" | \
    bin/kibana-keystore add elasticsearch.serviceAccountToken -x > /dev/null 2>&1
  touch "$FLAG_FILE_TOKEN_STORED"
fi

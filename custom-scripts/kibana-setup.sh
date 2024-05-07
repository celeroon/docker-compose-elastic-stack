#!/bin/bash

echo "Creating the kibana keystore"
bin/kibana-keystore create

echo "Making API request to generate Kibana token"
response=$(curl -s -X POST --cacert config/certs/elasticsearch-ca.pem -u elastic:${ELASTIC_PASSWORD} https://es01:9200/_security/service/elastic/kibana/credential/token/kibana_token)

echo "Extracting the token value from the JSON response using grep and awk"
token_value=$(echo "$response" | grep -o '"value":"[^"]*' | awk -F ':"' '{print $2}')

echo "Storing the token value securely using kibana-keystore"
echo -n "$token_value" | \
  bin/kibana-keystore add elasticsearch.serviceAccountToken -x > /dev/null 2>&1

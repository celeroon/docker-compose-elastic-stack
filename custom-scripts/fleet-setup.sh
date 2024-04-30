#!/bin/bash

echo "Creating an Agent Policy"
curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/agent_policies" \
    -d '{"id":"elastic-policy","name":"Elastic-Policy","namespace":"default","monitoring_enabled":["logs","metrics"]}' > /dev/null

echo "Creating a Package Policy"
curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
    -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/package_policies" \
    -d '{"name":"Elastic-System-package","namespace":"default","policy_id":"elastic-policy", "package":{"name": "system", "version":"1.54.0"}}' > /dev/null

echo "Adding a Fleet Server host"
curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/settings" \
    -d '{"fleet_server_hosts": ["https://fleet-server:8220"]}' > /dev/null

# CATing /certs/elasticsearch-ca.pem
cert_content=$(cat /certs/elasticsearch-ca.pem)

# Replacing newlines with "\\n" and store it in another variable
formatted_cert=$(echo -n "$cert_content" | sed -e 's/^/    /' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n    /g')

# Adding "\\n" to the beginning and end of the formatted string
formatted_cert="\"\\n$formatted_cert\\n\""

# Removing surrounding double quotes
formatted_cert=$(echo "$formatted_cert" | sed 's/^"\(.*\)"$/\1/')

# Constructing the new_variable with the certificate content
new_variable="ssl:\n  verification_mode: certificate\n  certificate_authorities: | $formatted_cert"

echo "Adding CA to fleet-server"
curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/fleet/outputs/fleet-default-output" \
    -d '{
      "hosts": ["https://es01:9200"],
      "config_yaml": "'"$new_variable"'"
    }' > /dev/null
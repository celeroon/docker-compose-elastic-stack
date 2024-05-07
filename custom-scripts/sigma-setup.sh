#!/bin/bash

echo "Enabling elastic default rules"
curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
    -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
    "https://kibana:5601/api/detection_engine/rules/prepackaged" 

# Convert Sigma rules to the NDJSON format for Elasticsearch
sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson sigma/rules/windows -o rules-windows.ndjson
sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson sigma/rules-emerging-threats -o rules-emerging-threats.ndjson
sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson sigma/rules-threat-hunting/windows -o rules-threat-hunting-windows.ndjson

# Loop over each ndjson file in the current directory
for file in *.ndjson
do
  echo "Uploading ${file}..."
  curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" -X POST -H "kbn-xsrf: true" -H "Content-Type: multipart/form-data" \
       --form "file=@${file}" \
       "https://kibana:5601/api/detection_engine/rules/_import" > /dev/null
done
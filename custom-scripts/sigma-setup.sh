#!/bin/bash

# Path to the flag directory
FLAG_DIR="/flags"

# Ensure the flag directory exists
mkdir -p "$FLAG_DIR"

# Flag files for each operation
FLAG_FILE_DEFAULT_RULES_ENABLED="$FLAG_DIR/default_rules_enabled"
FLAG_FILE_SIGMA_CONVERTED="$FLAG_DIR/sigma_converted"
FLAG_FILE_RULES_UPLOADED="$FLAG_DIR/rules_uploaded"

# Enabling elastic default rules if not already done
if [ ! -f "$FLAG_FILE_DEFAULT_RULES_ENABLED" ]; then
  echo "Enabling elastic default rules"
  curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
      -XPUT -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
      "https://kibana:5601/api/detection_engine/rules/prepackaged" 
  touch "$FLAG_FILE_DEFAULT_RULES_ENABLED"
fi

# Convert Sigma rules to the NDJSON format for Elasticsearch if not already done
if [ ! -f "$FLAG_FILE_SIGMA_CONVERTED" ]; then
  sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson sigma/rules/windows -o rules-windows.ndjson
  sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson sigma/rules-emerging-threats -o rules-emerging-threats.ndjson
  sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson sigma/rules-threat-hunting/windows -o rules-threat-hunting-windows.ndjson
  touch "$FLAG_FILE_SIGMA_CONVERTED"
fi

# Iterate over each .ndjson file in the current directory
for file in *.ndjson; do
    # Check if the file exists
    if [[ -f "$file" ]]; then
        # Use sed to find and replace "enabled": true with "enabled": false
        sed -i 's/"enabled": true/"enabled": false/g' "$file"
        echo "Processed $file"
    fi
done

echo "All .ndjson rules have been disabled."

# Upload NDJSON files to Elasticsearch if not already done
if [ ! -f "$FLAG_FILE_RULES_UPLOADED" ]; then
  for file in *.ndjson
  do
    echo "Uploading ${file}..."
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" -X POST -H "kbn-xsrf: true" -H "Content-Type: multipart/form-data" \
        --form "file=@${file}" \
        "https://kibana:5601/api/detection_engine/rules/_import" > /dev/null
  done
  touch "$FLAG_FILE_RULES_UPLOADED"
fi
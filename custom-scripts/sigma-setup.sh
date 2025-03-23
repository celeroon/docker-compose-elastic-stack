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
  echo "Converting Sigma rules to NDJSON..."

  # Array of source directories and their corresponding output files
  declare -A RULE_SETS=(
    ["sigma/rules/windows"]="rules-windows.ndjson"
    ["sigma/rules-emerging-threats"]="rules-emerging-threats.ndjson"
    ["sigma/rules-threat-hunting/windows"]="rules-threat-hunting-windows.ndjson"
  )

  for DIR in "${!RULE_SETS[@]}"; do
    OUTPUT_FILE="${RULE_SETS[$DIR]}"
    > "$OUTPUT_FILE"  # Clear the output file before writing

    # Process each .yml rule in the directory
    find "$DIR" -type f -name "*.yml" | while read -r rule; do
      echo "Processing $rule..."
      OUTPUT=$(sigma convert --target lucene --pipeline ecs_windows --format siem_rule_ndjson "$rule" 2>&1)

      if echo "$OUTPUT" | grep -q "Error"; then
        echo "Error: Conversion failed for rule $rule"
        continue
      fi

      echo "$OUTPUT" >> "$OUTPUT_FILE"
    done
  done

  touch "$FLAG_FILE_SIGMA_CONVERTED"
fi

# Iterate over each .ndjson file in the current directory
for file in *.ndjson; do
    if [[ -f "$file" ]]; then
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

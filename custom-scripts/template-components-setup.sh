#!/bin/bash

# Path to the flag directory
FLAG_DIR="/usr/share/logstash/flags"

# Ensure the flag directory exists
mkdir -p "$FLAG_DIR"

# Flag files for each operation
FLAG_FILE_COMPONENT_TEMPLATES="$FLAG_DIR/component_templates_loaded"
FLAG_FILE_INDEX_TEMPLATES="$FLAG_DIR/index_templates_loaded"
FLAG_FILE_ILM="$FLAG_DIR/ilm_loaded"
FLAG_FILE_INGEST_PIPELINE="$FLAG_DIR/ingest_pipeline_loaded"
FLAG_FILE_DASHBOARDS="$FLAG_DIR/dashboards_uploaded"

TEMPLATE_COMPONENTS_DIR="/usr/share/template-components"
INDEX_TEMPLATES_DIR="/usr/share/index-templates"
ILM_DIR="/usr/share/ilm"

function put_template_from_file() {
    local file_path="$1"
    local template_name=$(basename "$file_path" .json)  # Extract the base name and strip .json
    echo "Sending template '$template_name' from file '$file_path'"
    curl -X PUT --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://es01:9200/_component_template/$template_name" -H "Content-Type: application/json" --data-binary "@$file_path" > /dev/null
}

# Load component templates if not already done
if [ ! -f "$FLAG_FILE_COMPONENT_TEMPLATES" ]; then
    echo "Loading Component Templates"
    for file in $TEMPLATE_COMPONENTS_DIR/*.json; do
    if [[ -f "$file" ]]; then
        put_template_from_file "$file"
    else
        echo "No JSON files found in the directory."
    fi
    done
    touch "$FLAG_FILE_COMPONENT_TEMPLATES"
fi

function put_index_template_from_file() {
    local file_path="$1"
    local index_template_name=$(basename "$file_path" .json)  # Extract the base name and strip .json
    echo "Sending template '$index_template_name' from file '$file_path'"
    curl -X PUT --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://es01:9200/_index_template/$index_template_name" -H "Content-Type: application/json" --data-binary "@$file_path" > /dev/null
}

# Load index templates if not already done
if [ ! -f "$FLAG_FILE_INDEX_TEMPLATES" ]; then
    echo "Loading Index Templates"
    for file in $INDEX_TEMPLATES_DIR/*.json; do
    if [[ -f "$file" ]]; then
        put_index_template_from_file "$file"
    else
        echo "No JSON files found in the directory."
    fi
    done
    touch "$FLAG_FILE_INDEX_TEMPLATES"
fi

function put_ilm_from_file() {
    local file_path="$1"
    local ilm_name=$(basename "$file_path" .json)  # Extract the base name and strip .json
    echo "Sending template '$ilm_name' from file '$file_path'"
    curl -X PUT --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://es01:9200/_ilm/policy/$ilm_name" -H "Content-Type: application/json" --data-binary "@$file_path" > /dev/null
}

# Load ILM policies if not already done
if [ ! -f "$FLAG_FILE_ILM" ]; then
    echo "Loading ILM Policies"
    for file in $ILM_DIR/*.json; do
    if [[ -f "$file" ]]; then
        put_ilm_from_file "$file"
    else
        echo "No JSON files found in the directory."
    fi
    done
    touch "$FLAG_FILE_ILM"
fi

# Load ingest pipeline if not already done
if [ ! -f "$FLAG_FILE_INGEST_PIPELINE" ]; then
    echo "Loading ingest pipeline"
    curl -X PUT --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://es01:9200/_ingest/pipeline/add_event_ingested" -H "Content-Type: application/json" --data-binary "@/usr/share/logstash/config/add_event_ingested.json" > /dev/null
    touch "$FLAG_FILE_INGEST_PIPELINE"
fi

# Upload FortiGate dashboards if not already done
if [ ! -f "$FLAG_FILE_DASHBOARDS" ]; then
    echo "Uploading FortiGate dashboards"
    curl -X POST --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://kibana:5601/api/saved_objects/_import" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@/usr/share/logstash/config/fortigate-ELK-871.ndjson" > /dev/null
    touch "$FLAG_FILE_DASHBOARDS"
fi
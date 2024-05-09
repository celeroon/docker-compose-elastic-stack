DIRECTORY="/usr/share/template-components"

function put_template_from_file() {
    local file_path="$1"
    local template_name=$(basename "$file_path" .json)  # Extract the base name and strip .json
    echo "Sending template '$template_name' from file '$file_path'"
    curl -X PUT --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://es01:9200/_component_template/$template_name" -H "Content-Type: application/json" --data-binary "@$file_path" > /dev/null
    # echo -e "\nTemplate '$template_name' updated successfully"
}

# Iterate over each JSON file in the directory"
for file in $DIRECTORY/*.json; do
   if [[ -f "$file" ]]; then
       put_template_from_file "$file"
   else
      echo "No JSON files found in the directory."
   fi

done

echo "Loading ingest pipeline"
curl -X PUT --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" "https://es01:9200/_ingest/pipeline/add_event_ingested" -H "Content-Type: application/json" --data-binary "@/usr/share/logstash/config/add_event_ingested.json" > /dev/null

echo "Uploading FortiGate dashboards"
curl -X POST --cacert /usr/share/logstash/config/certs/elasticsearch-ca.pem -u "elastic:${ELASTIC_PASSWORD}" "https://kibana:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/usr/share/logstash/config/fortigate-ELK-871.ndjson"
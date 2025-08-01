#!/bin/bash

# Path to the flag directory
FLAG_DIR="/usr/share/elastic-agent/flags"

# Ensure the flag directory exists
mkdir -p "$FLAG_DIR"

# Flag files for each operation
FLAG_FILE_AGENT_POLICY="$FLAG_DIR/agent_policy_created"
FLAG_FILE_SYSTEM_PACKAGE="$FLAG_DIR/system_package_policy_created"
FLAG_FILE_WINDOWS_PACKAGE="$FLAG_DIR/windows_package_policy_created"
FLAG_FILE_NETWORK_PACKAGE="$FLAG_DIR/network_package_policy_created"
FLAG_FILE_EDR_PACKAGE="$FLAG_DIR/edr_package_policy_created"
FLAG_FILE_FLEET_SERVER_HOST="$FLAG_DIR/fleet_server_host_added"
FLAG_FILE_CA_ADDED="$FLAG_DIR/ca_added_to_fleet_server"

if [ ! -f "$FLAG_FILE_AGENT_POLICY" ]; then
    echo "Creating an Agent Policy"
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
        -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
        "https://kibana:5601/api/fleet/agent_policies" \
        -d '{"id":"windows-policy","name":"Windows-Policy","namespace":"default","monitoring_enabled":["logs","metrics"]}' > /dev/null
    touch "$FLAG_FILE_AGENT_POLICY"
fi

if [ ! -f "$FLAG_FILE_SYSTEM_PACKAGE" ]; then
    echo "Creating a System Package Policy"
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
        -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
        "https://kibana:5601/api/fleet/package_policies" \
        -d '{"name":"System","namespace":"default","policy_id":"windows-policy", "package":{"name": "system", "version":"2.3.0"}}' > /dev/null
    touch "$FLAG_FILE_SYSTEM_PACKAGE"
fi

if [ ! -f "$FLAG_FILE_WINDOWS_PACKAGE" ]; then
    echo "Creating a Windows Package Policy"
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
        -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
        "https://kibana:5601/api/fleet/package_policies" \
        -d '{"name":"Windows","namespace":"default","policy_id":"windows-policy","package":{"name":"windows","version":"1.44.5"}}' > /dev/null
    touch "$FLAG_FILE_WINDOWS_PACKAGE"
fi

if [ ! -f "$FLAG_FILE_NETWORK_PACKAGE" ]; then
    echo "Creating a Network Package Policy"
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
        -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
        "https://kibana:5601/api/fleet/package_policies" \
        -d '{"name": "Network-Traffic-1","namespace": "","policy_id": "windows-policy","enabled": true,"package": {"name": "network_traffic","title": "Network Packet Capture","version": "1.31.0"},"inputs": [{"type": "packet","policy_template": "network","enabled": true,"streams": [{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.amqp"},"vars": {"port": {"value": [5672],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"max_body_length": {"type": "integer"},"parse_headers": {"type": "bool"},"parse_arguments": {"type": "bool"},"hide_connection_information": {"type": "bool"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "amqp","ports": [5672],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.cassandra"},"vars": {"port": {"value": [9042],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"send_request": {"type": "bool"},"send_request_header": {"type": "bool"},"send_response": {"type": "bool"},"send_response_header": {"type": "bool"},"keep_null": {"type": "bool"},"compressor": {"type": "text"},"ignored_ops": {"value": [],"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "cassandra","ports": [9042],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.dhcpv4"},"vars": {"port": {"value": [67, 68],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"keep_null": {"type": "bool"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "dhcpv4","ports": [67, 68],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.dns"},"vars": {"port": {"value": [53],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"include_authorities": {"type": "bool"},"include_additionals": {"type": "bool"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "dns","ports": [53],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.flow"},"vars": {"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"period": {"value": "10s","type": "text"},"timeout": {"value": "30s","type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "flow","timeout": "30s","period": "10s","fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.http"},"vars": {"port": {"value": [80, 8080, 8000, 5000, 8002],"type": "text"},"monitor_processes": {"type": "bool"},"hide_keywords": {"value": [],"type": "text"},"send_headers": {"value": [],"type": "text"},"send_all_headers": {"type": "bool"},"redact_headers": {"value": [],"type": "text"},"include_body_for": {"value": [],"type": "text"},"include_request_body_for": {"value": [],"type": "text"},"include_response_body_for": {"value": [],"type": "text"},"decode_body": {"type": "bool"},"split_cookie": {"type": "bool"},"real_ip_header": {"type": "text"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"max_message_size": {"type": "integer"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "http","ports": [80, 8080, 8000, 5000, 8002],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": null,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.icmp"},"vars": {"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"keep_null": {"type": "bool"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "icmp","fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.memcached"},"vars": {"port": {"value": [11211],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"parseunknown": {"type": "bool"},"maxvalues": {"type": "integer"},"maxbytespervalue": {"type": "integer"},"udptransactiontimeout": {"type": "integer"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "memcache","ports": [11211],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.mongodb"},"vars": {"port": {"value": [27017],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"max_docs": {"type": "integer"},"max_doc_length": {"type": "integer"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "mongodb","ports": [27017],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.mysql"},"vars": {"port": {"value": [3306, 3307],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "mysql","ports": [3306, 3307],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.nfs"},"vars": {"port": {"value": [2049],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "nfs","ports": [2049],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.pgsql"},"vars": {"port": {"value": [5432],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "pgsql","ports": [5432],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.redis"},"vars": {"port": {"value": [6379],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"queue_max_bytes": {"type": "integer"},"queue_max_messages": {"type": "integer"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "redis","ports": [6379],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.sip"},"vars": {"port": {"value": [5060],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"use_tcp": {"value": false,"type": "bool"},"monitor_processes": {"type": "bool"},"parse_authorization": {"type": "bool"},"parse_body": {"type": "bool"},"keep_original": {"type": "bool"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "sip","ports": [5060],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.thrift"},"vars": {"port": {"value": [9090],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"transport_type": {"type": "text"},"protocol_type": {"type": "text"},"idl_files": {"value": [],"type": "text"},"string_max_size": {"type": "integer"},"collection_max_size": {"type": "integer"},"capture_reply": {"type": "bool"},"obfuscate_strings": {"type": "bool"},"drop_after_n_struct_fields": {"type": "integer"},"send_request": {"type": "bool"},"send_response": {"type": "bool"},"keep_null": {"type": "bool"},"transaction_timeout": {"type": "text"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "thrift","ports": [9090],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}},{"enabled": true,"data_stream": {"type": "logs","dataset": "network_traffic.tls"},"vars": {"port": {"value": [443, 993, 995, 5223, 8443, 8883, 9243],"type": "text"},"geoip_enrich": {"value": true,"type": "bool"},"monitor_processes": {"type": "bool"},"fingerprints": {"value": [],"type": "text"},"send_certificates": {"type": "bool"},"include_raw_certificates": {"type": "bool"},"keep_null": {"type": "bool"},"processors": {"type": "yaml"},"tags": {"value": [],"type": "text"},"map_to_ecs": {"type": "bool"}},"compiled_stream": {"type": "tls","ports": [443, 993, 995, 5223, 8443, 8883, 9243],"fields_under_root": true,"fields": {"_conf": {"geoip_enrich": true,"map_to_ecs": null}},"processors": null}}],"vars": {"interface": {"type": "text"},"never_install": {"value": false,"type": "bool"},"with_vlans": {"value": false,"type": "bool"},"ignore_outgoing": {"value": false,"type": "bool"}}}]}' > /dev/null
    touch "$FLAG_FILE_NETWORK_PACKAGE"
fi

if [ ! -f "$FLAG_FILE_EDR_PACKAGE" ]; then
    echo "Creating a Elastic Defend (EDR) Package Policy"
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
        -XPOST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
        "https://kibana:5601/api/fleet/package_policies" \
        -d '{"name":"EDR","namespace":"default","description":"","enabled":true,"package":{"name":"endpoint","title":"Elastic Defend","version":"8.18.1","requires_root":true},"policy_id":"windows-policy","policy_ids":["windows-policy"],"inputs":[{"type":"endpoint","enabled":true,"config":{"integration_config":{"value":{"type":"endpoint","endpointConfig":{"preset":"DataCollection"}}},"policy":{"value":{"meta":{"license":"basic","cluster_name":"'${CLUSTER_NAME}'","cloud":false,"serverless":false,"billable":false},"global_manifest_version":"latest","global_telemetry_enabled":true,"windows":{"events":{"credential_access":true,"dll_and_driver_load":true,"dns":true,"file":true,"network":true,"process":true,"registry":true,"security":true},"malware":{"mode":"detect","blocklist":true,"on_write_scan":true},"ransomware":{"mode":"off","supported":false},"memory_protection":{"mode":"off","supported":false},"behavior_protection":{"mode":"off","reputation_service":false,"supported":false},"popup":{"malware":{"message":"","enabled":true},"ransomware":{"message":"","enabled":false},"memory_protection":{"message":"","enabled":false},"behavior_protection":{"message":"","enabled":false}},"logging":{"file":"info"},"antivirus_registration":{"mode":"disabled","enabled":false},"attack_surface_reduction":{"credential_hardening":{"enabled":false}}},"mac":{"events":{"process":true,"file":true,"network":true},"malware":{"mode":"detect","blocklist":true,"on_write_scan":true},"behavior_protection":{"mode":"off","reputation_service":false,"supported":false},"memory_protection":{"mode":"off","supported":false},"popup":{"malware":{"message":"","enabled":true},"behavior_protection":{"message":"","enabled":false},"memory_protection":{"message":"","enabled":false}},"logging":{"file":"info"},"advanced":{"capture_env_vars":"DYLD_INSERT_LIBRARIES,DYLD_FRAMEWORK_PATH,DYLD_LIBRARY_PATH,LD_PRELOAD"}},"linux":{"events":{"process":true,"file":true,"network":true,"session_data":false,"tty_io":false},"malware":{"mode":"detect","blocklist":true,"on_write_scan":true},"behavior_protection":{"mode":"off","reputation_service":false,"supported":false},"memory_protection":{"mode":"off","supported":false},"popup":{"malware":{"message":"","enabled":true},"behavior_protection":{"message":"","enabled":false},"memory_protection":{"message":"","enabled":false}},"logging":{"file":"info"},"advanced":{"capture_env_vars":"LD_PRELOAD,LD_LIBRARY_PATH"}}}}},"streams":[]}],"vars":{}}' > /dev/null
    touch "$FLAG_FILE_EDR_PACKAGE"
fi

if [ ! -f "$FLAG_FILE_FLEET_SERVER_HOST" ]; then
    echo "Adding a Fleet Server host"
    curl --cacert /certs/elasticsearch-ca.pem -s -u "elastic:${ELASTIC_PASSWORD}" \
        -X POST -H "kbn-xsrf: kibana" -H "Content-type: application/json" \
        "https://kibana:5601/api/fleet/fleet_server_hosts" \
        -d '{"name": "fleet","host_urls": ["https://'"${FLEET_SERVER_HOST}"':8220"], "is_default": true}' > /dev/null
    touch "$FLAG_FILE_FLEET_SERVER_HOST"
fi

if [ ! -f "$FLAG_FILE_CA_ADDED" ]; then
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
        "hosts": ["https://'${ES_SERVER_HOST}':9200"],
        "config_yaml": "'"$new_variable"'"
        }' > /dev/null
    touch "$FLAG_FILE_CA_ADDED"
fi

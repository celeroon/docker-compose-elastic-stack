# Overview

I started with the Elasticsearch blog, [part 1](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose) and [part 2](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose-part-2). While those tutorials were helpful, I found that the generated certificates lacked passwords, and no keystores were configured. Therefore, I decided to build from scratch, implementing a full SSL chain configuration for secure communication between all components.

I would like to express my gratitude to [Evermight Tech](https://www.youtube.com/@evermighttech) and [Ali Younes](https://www.youtube.com/@AliYounesGo4IT) for their explanations and examples of configuring and securing Elasticsearch and its components.

Filebeat and Metricbeat are installed solely for monitoring Elasticsearch nodes and collecting logs.

# Usage

1. Generate and update encryption keys for Kibana in the `.env` file:

    ```bash
    chmod +x submit-es-fleet-addresses.sh
    ./submit-es-fleet-addresses.sh
    ```

2. To add external hosts as Elastic Agents, you need to specify the Fully Qualified Domain Name (FQDN) or IP address of your host where Docker is running to generate certificates (to include SAN entry in the certificate).

    ```bash
    chmod +x generate_kibana_encryptionkeys.sh
    ./generate_kibana_encryptionkeys.sh
    ```

3. Build and run:

    ```bash
    docker compose build
    docker compose up -d
    ```

After running the containers, you will find the `elasticsearch-ca.pem` certificate in the `certs/` directory. Use it to establish secure communications when adding Elastic Agents.

When generating the installation script for Elastic Agent (from Kibana GUI), replace the hostname `fleet-server` with your host's IP or FQDN submitted to the `.env` file.

In the `config` directory, you will find configuration files for Kibana, Metricbeat, Filebeat, and the Elasticsearch module for Filebeat.

In the `custom-scripts` directory, you can find setup scripts for Elasticsearch, Kibana, Fleet, and certificate generation.

> [!IMPORTANT]
> Update the hosts file with the entries for es01 and fleet-server on your elastic-agent host (ES_SERVER_HOST and FLEET_SERVER_HOST does not work for now)

# To-Do

- Integrate Logstash with pre-built [FortiDragon]((https://github.com/enotspe/fortinet-2-elasticsearch/blob/master/README.md)) pipelines for FortiGate.
- Test API keys instead of using passwords in Beats configuration.

# Links

https://www.elastic.co/guide/en/fleet/current/elasticsearch-output.html

https://medium.com/marionete/ui-less-fleet-managed-elastic-agents-a-guide-16106248249a

https://mpolinowski.github.io/docs/DevOps/Elasticsearch/2022-02-06--elasticsearch-v8-data-ingestion-apache/2022-02-06/

https://discuss.elastic.co/t/custom-log4j2-propoerties-for-elasticsearch-in-docker/310321

https://www.elastic.co/guide/en/beats/filebeat/current/setup-kibana-endpoint.html

https://www.elastic.co/guide/en/elasticsearch/reference/current/update-node-certs-different.html

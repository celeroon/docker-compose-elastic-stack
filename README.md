# Overview

I started with the Elasticsearch blog, [part 1](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose) and [part 2](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose-part-2). While those tutorials were helpful, I found that the generated certificates lacked passwords, and no keystores were configured. Therefore, I decided to build from scratch, implementing a full SSL chain configuration for secure communication between all components.

I would like to express my gratitude to [Evermight Tech](https://www.youtube.com/@evermightsystems) and [Ali Younes](https://www.youtube.com/@AliYounesGo4IT) for their explanations and examples of configuring and securing Elasticsearch and its components.

Filebeat and Metricbeat are installed solely for monitoring Elasticsearch nodes and collecting logs.

# Usage

1. Generate and update encryption keys for Kibana in the `.env` file:

    ```bash
    chmod +x generate_kibana_encryptionkeys.sh
    ./generate_kibana_encryptionkeys.sh
    ```

2. To add external hosts as Elastic Agents, you need to specify the Fully Qualified Domain Name (FQDN) or IP address of your host where Docker is running to generate certificates (to include SAN entry in the certificate):

    ```bash
    chmod +x submit-es-fleet-addresses.sh
    ./submit-es-fleet-addresses.sh
    ```

3. Make all the scripts in the custom-scripts directory executable:

    ```bash
    chmod +x custom-scripts/*
    ```

4. Build and run:

    ```bash
    docker compose build
    docker compose up -d
    ```

After running the containers, you will find the `elasticsearch-ca.pem` certificate in the `certs/` directory. Use it to establish secure communications when adding Elastic Agents.

In the `config` directory, you will find configuration files for Kibana, Metricbeat, Filebeat, and the Elasticsearch module for Filebeat.

In the `custom-scripts` directory, you can find setup scripts for Elasticsearch, Kibana, Fleet, and certificate generation.

## Acknowledgments

This project includes FortiGate pipeline configurations, ILM, dashboards, index and component templates were adapted from the [FortiDragon](https://github.com/enotspe/fortinet-2-elasticsearch/tree/master) project, which is licensed under the Apache License 2.0.

# Links

https://www.elastic.co/guide/en/fleet/current/elasticsearch-output.html

https://medium.com/marionete/ui-less-fleet-managed-elastic-agents-a-guide-16106248249a

https://mpolinowski.github.io/docs/DevOps/Elasticsearch/2022-02-06--elasticsearch-v8-data-ingestion-apache/2022-02-06/

https://discuss.elastic.co/t/custom-log4j2-propoerties-for-elasticsearch-in-docker/310321

https://www.elastic.co/guide/en/beats/filebeat/current/setup-kibana-endpoint.html

https://www.elastic.co/guide/en/elasticsearch/reference/current/update-node-certs-different.html

Also can be useful:

https://quoeamaster.medium.com/deploying-elasticsearch-and-kibana-with-docker-86a4ac78d851

https://miroslavpopovic.com/posts/2018/07/elasticsearch-with-aspnet-core-and-docker

https://apollin.com/elasticsearch-kibana-docker-custom-ports/

https://xyzcoder.github.io/2020/07/22/how-to-deploy-an-elastic-search-cluster-consisting-of-multiple-hosts-using-es-docker-image.html

https://medium.com/@karthiksdevopsengineer/setting-up-elasticsearch-and-kibana-single-node-cluster-with-docker-d785f591a760

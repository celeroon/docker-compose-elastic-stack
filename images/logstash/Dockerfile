ARG STACK_VERSION

FROM docker.elastic.co/logstash/logstash:${STACK_VERSION}

RUN /usr/share/logstash/bin/logstash-plugin remove logstash-input-twitter

RUN /usr/share/logstash/bin/logstash-plugin install --version 3.1.3 logstash-filter-tld
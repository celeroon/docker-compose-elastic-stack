FROM python:3

USER root

RUN git clone https://github.com/SigmaHQ/sigma.git
RUN python3 -m pip install sigma-cli
RUN sigma plugin install elasticsearch
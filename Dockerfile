ARG METABASE_VERSION
FROM metabase/metabase:${METABASE_VERSION}
USER root
RUN mkdir -p /opt/certs && wget -q https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -O /opt/certs/global-bundle.pem && chmod 644 /opt/certs/global-bundle.pem

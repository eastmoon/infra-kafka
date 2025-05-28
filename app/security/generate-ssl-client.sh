# Generate Kafka SSL key and certificate
# Ref : https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/Configuration_of_kafka_on_SSL.html

## Declare variable
PASS=$(cat /certs/cert_creds)

## Execute script
echo "----- Generate kafka.client.ssl.properties -----"
cat > /certs/kafka.client.ssl.properties <<EOF
security.protocol=SSL
ssl.keystore.location=/certs/kafka.client.keystore.jks
ssl.keystore.password=${PASS}
ssl.key.password=${PASS}
ssl.truststore.location=/certs/kafka.client.truststore.jks
ssl.truststore.password=${PASS}
EOF

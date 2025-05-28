# Generate Kafka SSL key and certificate
# Ref : https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/Configuration_of_kafka_on_SSL.html

## Declare variable
PASS='localhost1029384756'


## Execute script
echo "----- Check tools exists -----"
if [ $(command -v keytool | wc -l) -eq 0 ]; then
    echo "Command keytool not find."
    exit 1
fi
if [ $(command -v openssl | wc -l) -eq 0 ]; then
    echo "Command openssl not find."
    return 1
fi

echo "----- Remove legacy data -----"
rm /certs/*

echo "----- Generate cert_creds -----"
echo ${PASS} > /certs/cert_creds

echo "----- Generate CA ( certificate authority ) -----"
openssl req -new -x509 -config openssl-ca.cnf \
    -days 365 \
    -keyout /certs/ca.key \
    -out /certs/ca.cert \
    -passout pass:${PASS} \
    -subj "/C=EN/ST=State/L=Earth/O=Org/OU=Infra/CN=Kafka.Demo"

echo "----- Add CA in trust store -----"
[ -e /certs/kafka.server.truststore.jks ] && rm /certs/kafka.server.truststore.jks || true
keytool -import -alias CARoot -keystore /certs/kafka.server.truststore.jks \
    -storetype pkcs12 \
    -file /certs/ca.cert \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -noprompt

[ -e /certs/kafka.client.truststore.jks ] && rm /certs/kafka.client.truststore.jks || true
keytool -import -alias CARoot -keystore /certs/kafka.client.truststore.jks \
    -storetype pkcs12 \
    -file /certs/ca.cert \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -noprompt

echo "----- Generate Server keystore -----"
[ -e /certs/kafka.server.keystore.jks ] && rm /certs/kafka.server.keystore.jks || true
keytool -genkey -alias localhost -keystore /certs/kafka.server.keystore.jks \
    -keyalg RSA \
    -storetype pkcs12 \
    -validity 365 \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -dname "CN=Kafka.Server.Demo, OU=Infra, O=Org, L=Earth, ST=State, C=EN" \
    -ext SAN=DNS:localhost

echo "----- Export the certificate from the Server keystore -----"
keytool -certreq -alias localhost -keystore /certs/kafka.server.keystore.jks \
    -storepass ${PASS} \
    -file /certs/kefka.server.keystore.cert

echo "----- Sign Server certificate with CA -----"
openssl x509 -req -days 365 -CAcreateserial \
    -passin pass:${PASS} \
    -CA /certs/ca.cert \
    -CAkey /certs/ca.key \
    -in /certs/kefka.server.keystore.cert \
    -out /certs/kefka.server.keystore.cert-signed

echo "----- Add CA and sign-in certificate in Server keystore -----"
keytool -import -alias CARoot -keystore /certs/kafka.server.keystore.jks  \
    -storetype pkcs12 \
    -file /certs/ca.cert \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -noprompt
keytool -import -alias localhost -keystore /certs/kafka.server.keystore.jks  \
    -storetype pkcs12 \
    -file /certs/kefka.server.keystore.cert-signed \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -noprompt

echo "----- Generate Client keystore -----"
[ -e /certs/kafka.client.keystore.jks ] && rm /certs/kafka.client.keystore.jks || true
keytool -genkey -alias localhost -keystore /certs/kafka.client.keystore.jks \
    -keyalg RSA \
    -storetype pkcs12 \
    -validity 365 \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -dname "CN=Kafka.Client.Demo, OU=Infra, O=Org, L=Earth, ST=State, C=EN" \
    -ext SAN=DNS:localhost

echo "----- Export the certificate from the Client keystore -----"
keytool -certreq -alias localhost -keystore /certs/kafka.client.keystore.jks \
    -storepass ${PASS} \
    -file /certs/kefka.client.keystore.cert

echo "----- Sign Client certificate with CA -----"
openssl x509 -req -days 365 -CAcreateserial \
    -passin pass:${PASS} \
    -CA /certs/ca.cert \
    -CAkey /certs/ca.key \
    -in /certs/kefka.client.keystore.cert \
    -out /certs/kefka.client.keystore.cert-signed

echo "----- Add CA and sign-in certificate in Client keystore -----"
keytool -import -alias CARoot -keystore /certs/kafka.client.keystore.jks  \
    -storetype pkcs12 \
    -file /certs/ca.cert \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -noprompt
keytool -import -alias localhost -keystore /certs/kafka.client.keystore.jks  \
    -storetype pkcs12 \
    -file /certs/kefka.client.keystore.cert-signed \
    -keypass ${PASS} \
    -storepass ${PASS} \
    -noprompt

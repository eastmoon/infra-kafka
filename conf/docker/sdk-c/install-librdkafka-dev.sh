# Create confluent keyring
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.confluent.io/deb/7.9/archive.key | gpg --dearmor | tee /etc/apt/keyrings/confluent.gpg > /dev/null
# Create confluent sources list
cat > /etc/apt/sources.list.d/confluent-platform.sources << EOF
Types: deb
URIs: https://packages.confluent.io/deb/7.9
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/confluent.gpg

Types: deb
URIs: https://packages.confluent.io/clients/deb/
Suites: $(lsb_release -cs)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/confluent.gpg
EOF
# Donwload librdkafka-dev
apt-get update -y
apt-get install -y librdkafka-dev

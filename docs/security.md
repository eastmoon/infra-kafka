# Kafka 安全性

+ [Security](https://kafka.apache.org/documentation/#security)
    - [Docker image usage guide - Running in SSL mode](https://github.com/apache/kafka/blob/trunk/docker/examples/README.md#running-in-ssl-mode)
    - [Securing Your Kafka: A Beginner’s Guide to Kafka Security](https://medium.com/@bhattchitrangna/securing-your-kafka-a-beginners-guide-to-kafka-security-ab2978a4d82e)
    - [Authorization - course: Apache Kafka® Security](https://developer.confluent.io/courses/security/authorization/)
    - [Kafka Connect Security Basics](https://docs.confluent.io/platform/current/connect/security.html)
    - [Kafka authentication using SSL](https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/Configuration_of_kafka_on_SSL.html)
        + [Configuring Kafka Server with SSL authentication](https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/Config_Kafka_SSL.html)
        + [Configuring Kafka Server with SASL authentication](https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/ConfigKafkaSASL.html)
        + [Configuring Kafka Server with Kafka SASL_SSL](https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/Config_kafka_SASL_SSL.html)
    - [使用 SASL/SSL 連線到 Kafka](https://milvus.io/docs/zh-hant/connect_kafka_ssl.md)

## 監聽器與安全協議設定

每個監聽器的連結埠可以選擇不同的安全協議，其設定規則如下：

+ 利用 ```listeners``` 規劃監聽器，其結構為 ```{LISTENER_NAME}://{HOSTNAME}:{PORT}```
    - ```LISTENER_NAME```：監聽器名稱
    - ```HOSTNAME```：監聽的域名或網址
    - ```PORT```：監聽的連結埠
    - 環境變數 ```KAFKA_LISTENERS```
+ 利用 ```listener.security.protocol.map``` 設定監聽名稱與安全協議的對應，其結構```{LISTENER_NAME}:{SECURITY_PROTOCOL}```
    - ```SECURITY_PROTOCOL``` 安全協議包括以下設定
        + ```PLAINTEXT```：明文傳輸
        + ```SSL```：SSL 授權與加密傳輸
        + ```SASL_PLAINTEXT```：使用 SASL 授權，明文傳輸
        + ```SASL_SSL```：使用 SASL 授權，SSL 加密傳輸
    - 環境變數 ```KAFKA_LISTENER_SECURITY_PROTOCOL_MAP```
+ 利用 ```inter.broker.listener.name``` 指定代理 ( Broker ) 間通訊時採用的監聽器，通時會繼承監聽器的安全協議；但倘若未設定，則會基於 ```security.inter.broker.protocol``` 指定安全協議，其預設值為 ```PLAINTEXT```。
+ 利用 ```controller.listener.names``` 指定控制器 ( Controller ) 通訊採用的監聽器，但此監聽器不可與代理監聽器相同。

## SSL

[SSL/TLS](https://kafka.apache.org/documentation/#security_ssl) 是基於安全通訊端層 ( SSL、Secure Socket Layer ) 和傳輸層安全性 ( TLS、Transport Layer Security ) 協定為傳輸中的資料提供加密和驗證。

產生 Keystore 與 truststore 程序可以參考範本 [generate-ssl.sh](../app/security/generate-ssl.sh) 與下列文獻：

+ [Hands On: Setting Up Encryption - course: Apache Kafka® Security](https://developer.confluent.io/courses/security/hands-on-setting-up-encryption/)
+ [Kafka authentication using SSL](https://help.hcl-software.com/unica/Journey/en/12.1.4/Journey/AdminGuide/Configuration_of_kafka_on_SSL.html)

#### 範本設定

參考前述文獻，在 docker-compose 的 kafka-broker 設定如下環境變數：

```
# Configure listeners for both docker and host communication
KAFKA_LISTENERS: HOST://:9092, CONTROLLER://:9093, SSL://:9094
KAFKA_ADVERTISED_LISTENERS: HOST://:9092, CONTROLLER://:9093, SSL://:9094
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: HOST:PLAINTEXT, CONTROLLER:PLAINTEXT, SSL:SSL
# SSL configuration
KAFKA_SECURITY_PROTOCOL: SSL
KAFKA_SSL_KEYSTORE_FILENAME: kafka.server.keystore.jks
KAFKA_SSL_KEYSTORE_CREDENTIALS: cert_creds
KAFKA_SSL_KEY_CREDENTIALS: cert_creds
KAFKA_SSL_TRUSTSTORE_FILENAME: kafka.server.truststore.jks
KAFKA_SSL_TRUSTSTORE_CREDENTIALS: cert_creds
KAFKA_SSL_CLIENT_AUTH: 'required'
```

在設定過程中執行出現如下錯誤：

###### SSL 未啟動

```
ERROR Exiting Kafka due to fatal exception during startup. (kafka.Kafka$)
org.apache.kafka.common.config.ConfigException: Invalid value javax.net.ssl.SSLHandshakeException: No available authentication scheme for configuration A client SSLEngine created with the provided settings can't connect to a server SSLEngine created with those settings.
```

依據其他文獻的設定與資訊，在確認 [kafka-image 中的 confluent configure](https://github.com/confluentinc/kafka-images/blob/ad43da084067fab491873ba7f8686741f6731038/kafka/include/etc/confluent/docker/configure#L107-L118) 後，判斷為 Kafka 容器啟動時會依據 ```KAFKA_ADVERTISED_LISTENERS``` 變數中是否存在 SSL 字串，啟用 SSL 機制並複製必要資訊，如將 ```KAFKA_SSL_KEY_CREDENTIALS``` 轉換為 ```KAFKA_SSL_KEY_PASSWORD```。

雖然可將 ```KAFKA_SSL_KEY_CREDENTIALS``` 換成 ```KAFKA_SSL_KEY_PASSWORD``` 並直接填入密碼，但在指定 ```HOST:SSL``` 時會出現如下錯誤。

```
ERROR Exiting Kafka due to fatal exception during startup. (kafka.Kafka$)
org.apache.kafka.common.errors.InvalidConfigurationException: SSL key store is not specified, but key store password is specified.
```

因此，必需在 ```KAFKA_ADVERTISED_LISTENERS``` 填入如 ```SSL://[HOSTNAME]:[PORT]``` 字串。

###### SSL 未設定為安全協議

在實際測試中，在 ```KAFKA_LISTENERS``` 的設定必須對應 ```KAFKA_ADVERTISED_LISTENERS``` 的設定，詳細參考 [事件與訊息 - Step 6](./event-message.md#step-6-connecting-to-kafka-from-both-containers-and-native-apps) 中的解釋。

然而，在設定後會出現如下錯誤資訊：

```
Exception in thread "main" java.lang.IllegalArgumentException: Error creating broker listeners from 'HOST://:9092, CONTROLLER://:9093, SSL://:9094': No security protocol defined for listener SSL ...
```

嚴格來說，添加 SSL 開頭的 LISTENER_NAME 是為了配合 SSL 啟動，但 SSL 僅是名稱並未指定協議，因此需在 ```KAFKA_LISTENER_SECURITY_PROTOCOL_MAP``` 添加 ```SSL:SSL```。

###### INTER_BROKER 必須設定 ADVERTISED_LISTENERS

```
Exception in thread "main" java.lang.IllegalArgumentException: requirement failed: inter.broker.listener.name must be a listener name defined in advertised.listeners
```

在 [事件與訊息 - Step 6](./event-message.md#step-6-connecting-to-kafka-from-both-containers-and-native-apps) 中提過 ```KAFKA_ADVERTISED_LISTENERS``` 若無設定，則 會依據 ```KAFKA_LISTENERS``` 回應，然而若要啟動 SSL 必需設定 ```KAFKA_ADVERTISED_LISTENERS```，這導致預期的預設回應內容被此變數覆蓋，最終在 ```KAFKA_INTER_BROKER_LISTENER_NAME``` 設定一個存在 ```KAFKA_LISTENERS``` 但不存在 ```KAFKA_ADVERTISED_LISTENERS``` 的 LISTENER_NAME。

#### 範本測試

前述範本設定的特性如下：

+ 監聽器：SSL 為 SSL 傳輸，連結埠 9094
+ 安全協議為 SSL
    - keystore 為 kafka.server.keystore.jks
    - truststore 為 kafka.server.truststore.jks
    - 客戶端驗證 ( client.auth ) 為必需 ( required )

實際測試：

1、參考[事件與訊息 - 專案範例](./event-message.md#專案範例)執行，則 9092 依設定為明文傳輸，可正常運作。

2、參考[事件與訊息 - 專案範例](./event-message.md#專案範例)終執，並添加以下內容：

在 ```/app``` 目錄執行 [generate-ssl-client.sh](../app/security/generate-ssl-client.sh)，額外產生 ```kafka.client.ssl.properties``` 在 ```/certs``` 目錄。

在 ```/opt/kafka/bin``` 目錄執行 ```bash kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server kafka-broker:9094 --consumer.config /certs/kafka.client.ssl.properties```

經多次測試仍執行失敗，錯誤訊息如下；依據錯誤訊息與相關文件，研判是 Java 在啟用 SSL 時無法找到需要的資訊。

```
ERROR Error processing message, terminating consumer process:  (org.apache.kafka.tools.consumer.ConsoleConsumer)
org.apache.kafka.common.errors.SslAuthenticationException: SSL handshake failed
Caused by: javax.net.ssl.SSLHandshakeException: PKIX path validation failed: java.security.cert.CertPathValidatorException: Path does not chain with any of the trust anchors
```

雖然 [Creating your own CA - Kafka](https://kafka.apache.org/documentation/#security_ssl_ca) 文獻有提到 x509 模組錯誤，建議設定 openssl-ca.cnf，但執行 CA 簽章有額外錯誤訊息，尚無其他解決方案。

#### 結論

因最終客戶端運用 SSL 出現諸多 Kafka 隱含問題，且無法提供統一的解決方案，雖可開啟 SSL，但預期代理與代理、代理與客戶間執行應會出現異常。 

## SASL

[簡單認證與安全層 (SASL、Simple Authentication and Security Layer ) ](https://zh.wikipedia.org/zh-tw/%E7%AE%80%E5%8D%95%E8%AE%A4%E8%AF%81%E4%B8%8E%E5%AE%89%E5%85%A8%E5%B1%82) 提供了一個框架，用於為基於連接的協定添加身份驗證和資料安全服務。

在 Kafka 中，提供以下 SASL 機制：

+ [SASL/Kerberos](https://kafka.apache.org/documentation/#security_sasl_kerberos)，使用 [Kerberos](https://zh.wikipedia.org/zh-tw/Kerberos) 協定，由第三方的金鑰分發中心 ( KDC ) 負責伺服器或用戶端的認證協助，常見的如 Active Directory。
+ [SASL/PLAIN](https://kafka.apache.org/documentation/#security_sasl_plain)，使用帳號與密碼的簡單認證機制，通常搭配 TLS 進行加密。
+ [SASL/SCRAM](https://kafka.apache.org/documentation/#security_sasl_scram)，使用 [Salted 質詢回應驗證機制 ( SCRAM、Salted Challenge Response Authentication Mechanism )](https://en.wikipedia.org/wiki/Salted_Challenge_Response_Authentication_Mechanism)，用於解決 SASL/PLAIN 在執行帳號與密碼通訊時的安全性問題；主要可選擇 SCRAM-SHA-256 和 SCRAM-SHA-512 兩種 TLS 加密認證。
+ [SASL/OAUTHBEARER](https://kafka.apache.org/documentation/#security_sasl_oauthbearer)，使用 OAuth 2 授權框架，讓 Kafka 產生不安全的 JSON Web 令牌 ( Unsecured JSON Web Tokens )，但這並不建議使用於產品環境。
+ [Delegation Tokens](https://kafka.apache.org/documentation/#security_delegation_token)，在 SASL/SSL 機制上，由伺服器提供客戶端的委託令牌 ( Delegation tokens )，使用戶端可在短暫時間內存取訊息。

#### 範本設定

參考前述文獻，在 docker-compose 的 kafka-broker 設定如下環境變數：

```
# Configure listeners for both docker and host communication
KAFKA_LISTENERS: HOST://:9092, CONTROLLER://:9093, SASL_PLAINTEXT://:9095
KAFKA_ADVERTISED_LISTENERS: HOST://:9092, CONTROLLER://:9093, SASL_PLAINTEXT://:9095
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: HOST:PLAINTEXT, CONTROLLER:PLAINTEXT, SASL_PLAINTEXT:SASL_PLAINTEXT
# SASL configuration
KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: PLAIN
KAFKA_SASL_ENABLED_MECHANISMS: PLAIN
KAFKA_OPTS: "-Djava.security.auth.login.config=/etc/kafka/configs/kafka-server-jass.conf"
```

詳細帳號與密碼設定於 [kafka-server-jass.conf](../app/security/kafka-server-jass.conf) 設定檔，對設定檔有以下要注意：

+ ```username``` 與 ```password``` 適用於代理之間建立連線使用
+ ```user_[username]``` 為代理與代理、代理與客戶間的帳號
    - ```user_admin="admin-secret"```，其意思為帳號 admin 其密碼為 admin-secret

需注意，在前述 [SSL 未啟動](#SSL 未啟動) 與 [SSL 未設定為安全協議](#SSL 未設定為安全協議) 同樣會出現在 SASL 設定中。

#### 範本測試

前述範本設定的特性如下：

+ 監聽器：SASL_PLAINTEXT 為 SASL_PLAINTEXT 傳輸，連結埠 9095
+ SASL 機制為 PLAIN

實際測試：

1、參考 [Kafka 客戶端 - Python](./client.md#Python)執行，利用 Python 客戶端，由 ```produce.py``` 發送於 9092，由 ```consumer.py``` 監聽 9092，執行正常。

2、添加 [producer-sasl.py](../app/client-python/producer-sasl.py)，並增加相關 SASL 設定；由 由 ```produce-sasl.py``` 發送於 9095，由 ```consumer.py``` 監聽 9092，執行正常。

## [Authorization and ACLs](https://kafka.apache.org/documentation/#security_authz)

本節提到授權 ( Authorization ) 與存取控制列表 ( Access Control Lists ) 的設定方式，藉由這項設定，限制用戶可以存取甚麼樣的主題、來自那個網址的人可讀取甚麼主題。

## [SSL vs SASL](https://developer.confluent.io/courses/security/securing-zookeeper/#ssl-vs-sasl)

SSL 在管理上憑證較為繁瑣，但它是最受歡迎的，且容易使用；倘若整體系統存在 Kerberos 等第三方服務，那可使用 SASL 較為適當。

在 Kafka 的設計上，可以同時使用兩者，使用 SSL 進行身份驗證，使用 SASL 來確定存取和授予授權，其優點是客戶端不需要使用相同的可分辨名稱，因此您不必設定唯一性的主題名稱。

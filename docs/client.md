# Kafka 客戶端

+ [Kafka API](https://kafka.apache.org/documentation/#api)
+ [Apache Kafka Clients](https://cwiki.apache.org/confluence/display/KAFKA/Clients)
    - [Apache Kafka Clients - confluent](https://docs.confluent.io/kafka-clients/overview.html)
    - [librdkafka - the Apache Kafka C/C++ client library](https://github.com/confluentinc/librdkafka)
        + [Getting Started with Apache Kafka and C/C++](https://developer.confluent.io/get-started/c/)
        + [C/C++ Client for Apache Kafka](https://docs.confluent.io/kafka-clients/librdkafka/current/overview.html)
        + [Broker version compatibility](https://github.com/confluentinc/librdkafka/blob/master/INTRODUCTION.md#broker-version-compatibility)
        + [Install Confluent Platform using Systemd on Ubuntu and Debian](https://docs.confluent.io/platform/current/installation/installing_cp/deb-ubuntu.html#systemd-ubuntu-debian-install)
    - [Confluent's Python Client for Apache KafkaTM](https://github.com/confluentinc/confluent-kafka-python)
        + [Getting Started with Apache Kafka and Python](https://developer.confluent.io/get-started/python/)

當 Kafka 完成後，可以利用其 Kafka 安裝包內 ```bin``` 目錄的腳本進行基本的操作與演練，亦即在[事件與訊息](./event-message.md)文件中的操作範本；倘若運用於系統維運，可以在訊息發送端啟用文件中的 kafka-client ( 不啟動 Kafka 的 Kafka 容器 ) 來接收與發送訊息，然而，若要提高處理效率或應用於不同的應用程式中，則需基於相應的程式語言導入函示庫，以便配合應用程式的業務邏輯來收發訊息。

依據上述連結，[Kafka API](https://kafka.apache.org/documentation/#api) 提供了在 Java 的函示庫，[Apache Kafka Clients](https://cwiki.apache.org/confluence/display/KAFKA/Clients) 則提供了主流語言 C、Python、Go、Node.js 等的函示庫。

本專案僅以 C、Python 進行範例實驗，詳細的函示庫操作與規劃細節不在此討論，請參閱上述連結的官方文獻；此外，以下範本僅設計 producer 與 consumer 的執行，請在執行前參考[事件與訊息 - 專案範例](./event-message.md#專案範例)文件，建立必要的主題 ( Topic )。

## C

Kafka 的 C 函示庫主要名為 librdkafka，本專案範本於 [sdk-c](../conf/docker/sdk-c) 中的 Dockerfile 建立 C 編譯工具與相依函示庫，進入開發環境請使用運維 CLI ：

```
## 啟動服務
kafka up

## 進入容器
kafak into --tag=kafka-client-c
```

#### 函示庫相依

依據上述文獻，Kafka 的 C 語言函示庫主要需要兩個函示庫：

+ pkg-config：提供給 make 配置檔使用的 Linux 工具
+ libglib2.0-dev：提供 GNU 函示庫

#### 安裝注意事項

由於 Debian 函示庫中保存的 librdkafka-dev 僅有 0.11.6，對應到最新的 Kafka 容器會出現如下錯誤訊息：

```
Consumer error: JoinGroup failed: Local: Required feature not supported by broker
```

為修正此錯誤，librdkafka-dev 的 Github 推薦從 Confluent Platform 安裝，設定方式可以參考上述連結或本專案的安裝腳本 [install-librdkafka-dev.sh](../conf/docker/sdk-c/install-librdkafka-dev.sh)；在完成設定後，可以用以下指令檢查目前 sources 列表中可下載的版本清單：

```
apt-cache show librdkafka-dev
```

在確認清單中存在新版本的 librdkafka-dev 後，即可用以下指令安裝函示庫：

```
apt-get update -y
apt-get install -y librdkafka-dev
```

#### 編譯程式

本專案範本參考上述文獻內容，並依據專案的 Kafka 設定相應參數與移除不必要參數，其程式內容參考：

+ [producer](../app/client-c/producer.c)
+ [consumer](../app/client-c/consumer.c)

```
## 編譯 producer
make producer

## 編譯 consumer
make consumer
```

#### 執行方法

完成編譯後，會在專案目錄保留可執行檔，請透過以下指令執行相應操作。

```
## 執行 producer
./producer

## 執行 consumer
./consumer
```

若在單一命令列執行，原則上 consumer 會接收到 producer 先前發出的內容；倘若要測試即時狀態，可開啟兩個命令列，分別進入容器後執行不同的程式，亦或利用 Python 客戶端進行交叉測試。

## Python

Kafka 的 Python 函示庫主要名為 confluent-kafka，本專案範本於 [sdk-python](../conf/docker/sdk-python) 中的 Dockerfile 建立 Python 開發環境，進入開發環境請使用運維 CLI ：

```
## 啟動服務
kafka up

## 進入容器
kafak into --tag=kafka-client-python
```

#### 執行方法

本專案範本參考上述文獻內容，並依據專案的 Kafka 設定相應參數與移除不必要參數，其程式內容參考：

+ [producer](../app/client-python/producer.py)
+ [consumer](../app/client-python/consumer.py)

不同於 C 語言，Python 為直譯語言，其開發環境等同執行環境，因此僅需進入容器後執行即可：

```
## 執行 producer
python producer.py

## 執行 consumer
python consumer.py
```

若在單一命令列執行，原則上 consumer 會接收到 producer 先前發出的內容；倘若要測試即時狀態，可開啟兩個命令列，分別進入容器後執行不同的程式，亦或利用 C 客戶端進行交叉測試。

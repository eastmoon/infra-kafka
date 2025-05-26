# Kafka 連結器 ( Connector )

+ [Kafka Connect](https://kafka.apache.org/documentation.html#connect)
    - [Introduction to Kafka Connectors](https://www.baeldung.com/kafka-connectors-guide)
    - [How to Use Kafka Connect - Get Started](https://docs.confluent.io/platform/current/connect/userguide.html#connect-configuring-converters)
    - [Introduction to Kafka Connect](https://developer.confluent.io/courses/kafka-connect/intro/)
+ [Step 6: Import/export your data as streams of events with Kafka Connect](https://kafka.apache.org/quickstart#quickstart_kafkaconnect)
    - [Kafka Connect FileStream Connectors](https://docs.confluent.io/platform/current/connect/filestream_connector.html)
    - [Configure Self-Managed Connectors](https://docs.confluent.io/platform/current/connect/configuring.html#connect-managing-config-connectors)
    - [Configuring key and value converters](https://docs.confluent.io/platform/current/connect/userguide.html#connect-configuring-converters)
    - [Kafka Connect’s REST API](https://developer.confluent.io/courses/kafka-connect/rest-api/)
        + [Kafka Connect REST Interface for Confluent Platform](https://docs.confluent.io/platform/current/connect/references/restapi.html)
+ [Connector Developer Guide](https://docs.confluent.io/platform/current/connect/devguide.html)
    - [FileStreamSourceConnector.java](https://github.com/apache/kafka/blob/trunk/connect/file/src/main/java/org/apache/kafka/connect/file/FileStreamSourceConnector.java)
    - [FileStreamSinkConnector.java](https://github.com/apache/kafka/blob/trunk/connect/file/src/main/java/org/apache/kafka/connect/file/FileStreamSinkConnector.java)
+ [Confluent Hub](https://www.confluent.io/hub/)
    - [A Complete Comparison of Confluent vs. Apache Kafka®](https://www.confluent.io/apache-kafka-vs-confluent/)

## Clinet vs Connector

若說客戶端 ( Client ) 是提供不同語言對 Kafka 的操作函示庫，連結器 ( Connector ) 就是提供不同第三方服務的 Kafka 訊息接收與發送服務。

![](./img/ingest-data-upstream-systems.jpg)
> from [Introduction to Kafka Connect](https://developer.confluent.io/courses/kafka-connect/intro/)

在 Kafka 的連結器中，主要分成兩個類型：

+ 來源 ( Source )：自第三方服務提取內容，傳遞給 Kafka；其本質為第三服務 API 操作加上 Producer 操作。
+ 沉澱 ( Sink )：自 Kafka 接收訊息，並轉換為相應服務可處裡的內容，其本質為 Consumer 操作加上第三方服務 API 操作。

## 啟動服務

在 Kafka 的連結器本身屬於一種客戶端；因此，本專案範例參考[事件與訊息 - 專案範例](./event-message.md#專案範例)的設計方式，並做以下調整：

+ 基於 Kafka 容器提供 FileStream 連結器範本設計
+ 配合補充文件填寫完整參數檔，並放置於 [connect-file](../app/connect-file) 目錄中
    - [connect-standalone.properties](../app/connect-file/connect-standalone.properties) 為啟動連結器時的共通配置檔
    - [connect-source.properties](../app/connect-file/connect-source.properties) 為來源連結器的細部配置檔
    - [connect-sink.properties](../app/connect-file/connect-sink.properties) 為沉澱連結器的細部配置檔
+ 使用 Kafka 指令啟動連結器
    - 指令結構 ```connect-standalone.sh common_properties_file [connector_1_properties_file, ..., connector_N_properties_file]```
        + ```common_properties_file``` 為前述的 connect-standalone.properties 檔案
        + ```[connector_1_properties_file ... connector_N_properties_file]``` 依據要啟動的 Connector 提供相應的配置檔，在此使用 connect-source.properties 與 connect-sink.properties

執行本專案範例構築的環境，需執行如下命令：

```
## 啟動服務
kafka up

## 進入容器
kafka into --tag=kafka-connect-file
```

依據範本設定，來源檔案串流連結器會將 ```/data/test.txt``` 內容上傳到 ```connect-test``` 主題，而沉澱檔案串流連結器會將 ```connect-test``` 主題提取並寫入 ```/data/test.sink.txt```，因此可以進行以下操作：

```
## 寫入內容
echo "test-text" >> /data/test.txt

## 檢查內容
grep "test-text" /data/test.sink.txt
```

## REST API

在 Kafka 中，連結器會提供 REST API 讓第三方服務檢查連結器狀態，其服務的連結埠預設為 8083，若要改變應在前述的 connect-standalone.properties 增加配置參數 ```listeners=http://localhost:8080,https://localhost:8443```，其中 https 需要配合 ssl 相關配置參數。

執行本專案範例構築的環境，需執行如下命令：

```
## 啟動服務
kafka up

## 取得啟動的連結器列表
curl http://localhost:8083/connectors

## 取得檔前容器內可使用的連結器插件列表
curl http://localhost:8083/connector-plugins
```

## 自定連結器

若開發訊息傳遞程式，需要符合連結器的使用方式 ( 獨立容器與配置方式、REST API 操作服務 )，則可參考前述文獻 [Connector Developer Guide](https://docs.confluent.io/platform/current/connect/devguide.html) 來設計專屬的連結器。

需注意，不同於客戶端有多種語言支持，設計連結器必需為 Java 專案，建議參考範本庫 [connect-file](https://github.com/apache/kafka/tree/trunk/connect/file/src/main/java/org/apache/kafka/connect/file) 的設計結構來延伸。

## Confluent Hub

在調查連結器時，多數文建會參考到 Confluent，且文獻也會提到可以自 Confluent hub 下載連結器使用，在此補充說明 Kafka 與 Confluent 的差異：

Kafka 專注於訊息柱列與傳遞的開源軟體，Confluent 則是基於 Kafka 串流機制配合 Flink 等服務的整合平台，亦可說 Confluent 是 Kafka 的商業運營版本。

因此，Confluent 團隊專注在 Kafka 上提供了多樣的連結器，但可供地端使用的版本皆僅有 30 天免費試用，其後需提供商業授權，若有無授權的連結器，其使用範圍多為 Confluent 雲端平台。

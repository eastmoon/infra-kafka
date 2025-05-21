# Kafka

**Kafka是由Apache軟體基金會開發的一個開源流處理平台，由Scala和Java編寫。該專案的目標是為處理即時資料提供一個統一、高吞吐、低延遲的平台。其持久化層本質上是一個「按照分散式事務紀錄檔架構的大規模釋出/訂閱訊息佇列」，這使它作為企業級基礎設施來處理串流資料非常有價值。**
> From [Kafka - Wiki](https://zh.wikipedia.org/zh-tw/Kafka)

## 專案操作

+ 啟動

使用 CLI 呼叫 docker-compose 來啟動相關服務

```
kafka up
```
> 預設啟用 OSS 版本，若要使用企業版則添加參數 ```--ent```

+ 關閉

使用 CLI 呼叫 docker-compose 來關閉相關服務

```
kafka down
```

+ 進入

使用 CLI 進入目標容器內來操作相關服務的命令

```
kafka into --tag=[service-name]
```

## 功能與設計

### 介紹

對於 Kafka 軟體整體的簡介，詳細文獻整理參閱 [Kafka 介紹](./docs/introduction.md)。

對於 Kafka 軟體核心概念與設計案例說明，詳細文獻整理參閱 [Kafka 設計概念](./docs/concept.md)。

### 事件與訊息

本節基於 Kafka 基本使用方式，完成訊息傳遞與接收的範本，詳細文獻整理參閱 [事件與訊息](./docs/event-message.md)

### 用戶

### 用戶端

### 連結器

### 安全性

## 文獻

+ [Kafka](https://kafka.apache.org/documentation/)
    - [Kafka - Wiki](https://zh.wikipedia.org/zh-tw/Kafka)
    - [Kafka - Docker](https://hub.docker.com/r/apache/kafka)
    - [Kafka Streams](https://kafka.apache.org/documentation/streams/)
        + [Architecture](https://kafka.apache.org/34/documentation/streams/architecture)
    - [Kafka Ecosystem](https://cwiki.apache.org/confluence/display/KAFKA/Ecosystem)
        + [Apache Samza](https://samza.apache.org/)
        + [Apache Airflow](https://airflow.apache.org/docs/apache-airflow-providers-apache-kafka/stable/operators/index.html)
+ Client
    - [Kafka Python](https://kafka-python.readthedocs.io/en/master/)
+ Tutorial
    - [RUN KAFKA STREAMS DEMO APPLICATION](https://kafka.apache.org/34/documentation/streams/quickstart)
    - [TUTORIAL: WRITE A KAFKA STREAMS APPLICATION](https://kafka.apache.org/34/documentation/streams/tutorial)
+ Paper
    - [KSQL: Streaming SQL Engine for Apache Kafka](https://openproceedings.org/2019/conf/edbt/EDBT19_paper_329.pdf)
    - [Apache Kafka 2.8不再需要ZooKeeper就能運作](https://www.ithome.com.tw/news/143569)
        + [Apache ZooKeeper - Wiki](https://zh.wikipedia.org/zh-tw/Apache_ZooKeeper)

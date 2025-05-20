# Kafka 介紹

+ [Introduction](https://kafka.apache.org/documentation/#introduction)

## What is event streaming?

事件流相當於人體中樞神經系統的數位版本。它是「永遠在線」世界的技術基礎，在這個世界中，企業越來越多的運用軟體定義和自動化技術，使用者也能靈活運用軟體。

從技術上講，事件流是從事件來源（如資料庫、感測器、行動裝置、雲端服務和軟體應用程式）以事件流的形式即時擷取資料的實踐，諸如：

+ 持久儲存這些事件流以供日後檢索
+ 即時和回顧性地操作、處理和回應事件流
+ 根據需要將事件流導引到不同的技術終端

因此，事件流確保了資料的連續流動和解釋，以便正確的資訊在正確的時間出現在正確的地點。

## What can I use event streaming for?

事件流廣泛應用於眾多產業和組織，其範例如下列：

+ 即時處理支付和金融交易，例如證券交易所、銀行和保險公司。
+ 即時追蹤和監控汽車、卡車、車隊和貨物，例如在物流和汽車行業。
+ 持續擷取和分析來自物聯網設備或其他設備（例如工廠和風力發電場）的感測器資料。
+ 收集並立即回應客戶互動和訂單，例如在零售、酒店和旅遊業以及行動應用程式中。
+ 監測住院患者並預測病情變化，以確保在緊急情況下及時治療。
+ 連接、儲存和提供公司不同部門產生的資料。
+ 作為資料平台、事件驅動架構和微服務的基礎。

## Apache Kafka® is an event streaming platform. What does that mean?

And all this functionality is provided in a distributed, highly scalable, elastic, fault-tolerant, and secure manner. Kafka can be deployed on bare-metal hardware, virtual machines, and containers, and on-premises as well as in the cloud. You can choose between self-managing your Kafka environments and using fully managed services offered by a variety of vendors.

Kafka 結合了三種關鍵功能：

+ 發布（寫入）和訂閱（讀取）事件流，包括從其他系統持續匯入/匯出資料。
+ 根據需要持久可靠地儲存事件流。
+ 當事件發生或回顧記錄時處理事件流內容。

Kafka 這些功能，可以分散式、高擴展、彈性、容錯和安全的方式運用，並可部署在實體主機、虛擬機器、容器、雲端。

## How does Kafka work?

Kafka 是一個分散式系統，由伺服器和用戶端組成，並由高效的 TCP 網路協定進行通訊。

+ 伺服器 ( Server )
    - 運行 Kafka 叢集需至少一個伺服器
    - 伺服器可跨越多個資料中心或雲端區域
    - 伺服器構成包括資訊儲存的代理 ( Broker )，持續以事件流匯入和匯出數據的連結 ( Coonect )
    - 可與其他現有的系統 ( 如關聯式資料庫以及其他 Kafka 叢集 ) 整合，構築更加龐大的系統
    - 叢集具有高度可擴展性和容錯性，若任何伺服器發生故障，其他伺服器將接管其工作，以確保持續運行而不會遺失任何資料


+ 客戶端 ( Client )
    - 可設計成分散式應用程式和微服務，經由網路環境實踐大規模並行的容錯讀取、寫入事件流處理系統
    - 由 Kafka 社群提供的數十個客戶端
    - 適用於 Java 和 Scala 語言的 Kafka Streams 函式庫，以及適用於 Go、Python、C/C++ 和許多其他程式語言的 REST API

## Main Concepts and Terminology

事件記錄「發生某事」的事實，在文件中也被稱為記錄或訊息。當向 Kafka 讀取或寫入資料時，此操作會以事件的形式執行。從概念而論，事件具有鍵 ( Key )、值 ( Value )、時間戳記 ( Timestamp ) 和額外的數據或資料，以下是一個事件的範例：

```
Event key: "Alice"
Event value: "Made a payment of $200 to Bob"
Event timestamp: "Jun. 25, 2020 at 2:06 p.m."
```

在 Kafka 中，生產者 ( Producers ) 是向 Kafka 發布 ( 寫入 ) 事件的客戶端應用程序，而消費者 ( Consumers ) 是訂閱 ( 讀取和處理 ) 這些事件的客戶端應用程式，且生產者和消費者是完全解耦且彼此不知對方的存在。

在 Kafka 中，事件被彙整並持久地儲存在主題 ( Topics ) 中，主題如同檔案系統中的資料夾，事件是該資料夾中的檔案，其特性如下：

+ 主題始終對應於多個生產者和多個消費者，一個主題至少有零個以上的生產者向其寫入事件，且至少零個以上以的消費者讀取事件。
+ 主題中的事件可以根據需要隨時讀取，不同與傳統訊息傳遞系統，事件在被讀取後不會刪除。
+ 每個主題需配置設定來定義 Kafka 應保留事件的時間長度，超過時間會自動刪除舊事件。
+ Kafka 的讀寫效能與資料大小無關，因此可長時間儲存資料。

在 Kafka 中，主題 ( Topics ) 會分散儲存在不同的 Kafka 代理 ( Broker ) 的儲存桶 ( Buckets )，考量叢集架構中 Kafka 實際會有多個代理提供給客戶端讀寫事件，當新事件寫入至主題時，其實際會被轉移到該主題所在的 Kafka 代理的儲存桶中。

而 Kafka 為了實踐容錯性 ( fault-tolerant ) 和高可用性 ( highly-available )，每個主題都會被複製到不同的 Kafka 代理，從而讓每個代理擁有資料副本，確保當特定代理異常、維修等狀況發生，事件資料仍存在且可持續被讀寫；實務產品環境中，Kafka 叢集中會將主題複製三份副本。

詳細的 Kafka 架構設計概念與理論，可參閱整理文獻[設計](./concept.md)。

## MQTT vs KAFKA

+ [What is the difference between MQTT broker and Apache Kafka](https://stackoverflow.com/questions/37391827)

MQTT 僅是通訊協定 ( Protocol )，主旨在輕量的客戶端 ( Client ) 與訊息代理 ( Message Broker ) 間的發佈 ( Publish ) 與訂閱 ( Subscribe ) 訊息交換。

Kafka 是訊息代理 ( Message Broker )，且基於 **commit log*** 概念設計；其設計著重於將大量資料儲存於硬碟，並允許即時或稍後使用；且設計為可多節點叢集部屬，具有良好的擴展性、容錯性、高可用性；此外，Kafka 使用自家的通訊協議。

MQTT 是標準的發佈與訂閱協議，Kafka 是具體的訊息儲存 ( storing ) 與散佈 ( distributing ) 軟體；運用上，可以下列方式區分使用時機：

+ 如果您需要儲存大量訊息，以確保批次處理，則選擇 Kafka。
+ 如果您有很多客戶端需藉由主題即時交換訊息，則選擇實踐 MQTT ( mosquitto ) 或 AMQP ( RabbitMQ ) 的軟體。

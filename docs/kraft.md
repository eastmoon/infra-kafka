# Kafka Raft

+ [KRaft](https://kafka.apache.org/documentation/#kraft)
    - [Differences Between KRaft mode and ZooKeeper mode](https://kafka.apache.org/40/documentation/zk2kraft.html)
    - [KRaft: Apache Kafka Without ZooKeeper](https://developer.confluent.io/learn/kraft/)
    - [Apache Kafka 3.0.0持續更新共識機制KRaft，並著手清理舊支援與設定](https://www.ithome.com.tw/news/146866)

Apache Kafka Raft（KRaft）是 KIP-500 中引入的共識協議，旨在消除 Apache Kafka 對 ZooKeeper 進行元資料管理的依賴。透過將元資料的責任整合到 Kafka 本身，而不是將其拆分到 ZooKeeper 和 Kafka 兩個不同的系統，這大大簡化了 Kafka 的架構。

KRaft 模式利用 Kafka 中的新仲裁控制器服務來取代先前的控制器，並利用基於事件的 [Raft](https://zh.wikipedia.org/zh-tw/Raft) 共識協議變體。

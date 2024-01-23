package com.example.kafka;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.time.Instant;
import java.util.Properties;

public class BatchProducerWithHeader {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        Producer<String, String> producer = new KafkaProducer<>(props);
        String topic = "example-topic";

        for (int i = 0; i < 100; i++) {
            ProducerRecord<String, String> record = new ProducerRecord<>(topic, Integer.toString(i), "Message " + i);
            //you could probably move this before the for loop and just use the same value for each record
            long epochMillis = Instant.now().toEpochMilli();

            record.headers().add("time-entered-queue", Long.toString(epochMillis).getBytes());
            producer.send(record);
        }

        producer.close();
    }
}
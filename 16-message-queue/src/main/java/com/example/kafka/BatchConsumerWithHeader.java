package com.example.kafka;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.header.Header;
import org.apache.kafka.common.serialization.StringDeserializer;

import io.opentelemetry.api.trace.Span;

import java.time.Duration;
import java.time.Instant;
import java.util.Collections;
import java.util.Properties;

public class BatchConsumerWithHeader {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("group.id", "example-group");
        props.put("key.deserializer", StringDeserializer.class.getName());
        props.put("value.deserializer", StringDeserializer.class.getName());
        props.put("enable.auto.commit", "true");
        props.put("auto.commit.interval.ms", "1000");

        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        String topic = "example-topic";
        consumer.subscribe(Collections.singletonList(topic));

        int batchSize = 10;
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
            if (records.count() >= batchSize) {
                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value());

                    Header header = record.headers().lastHeader("time-entered-queue");
                    if (header != null) {
                        Long produced_epoch_time = Long.parseLong(new String(header.value()));
                        long consumed_epoch_time = Instant.now().toEpochMilli();
                        long time_in_queue = consumed_epoch_time - produced_epoch_time;
                        Span span = Span.current();
                        span.setAttribute("app.kafka_queue_time", time_in_queue);
                        System.out.println("Header: " + header.key() + " = " + produced_epoch_time);
                    }
                }
            }
        }
    }
}
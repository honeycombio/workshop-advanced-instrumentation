#!/bin/bash

kafka-topics --create --topic example-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1


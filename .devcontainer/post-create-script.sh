#!/bin/bash
# rm current link and relink it to jvm 21
cd /home/codespace/java
rm current && ln -s 21.0.4-ms current

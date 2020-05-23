#!/bin/sh

/usr/ServerAgent-2.2.3/jdk-13.0.1/bin/java -jar $(dirname $0)/CMDRunner.jar --tool PerfMonAgent "$@"&

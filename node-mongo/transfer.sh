#!/usr/bin/env bash
tar -zcvf results.tar.gz results
curl --upload-file ./results.tar.gz https://transfer.sh/node-mongo-results.tar.gz
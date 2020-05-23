#!/usr/bin/env bash
apt-get -y install jq

generate_configurations () {
> node_mongo_getbyid_10.yml
> node_mongo_getbyid_100.yml
> node_mongo_patch_10.yml
> node_mongo_patch_100.yml
> node_mongo_delete_1.yml
echo "---
services:
- module: monitoring
  ^local:
  server-agent:
  - address: node:4444
    logging: True
    metrics:
    - cpu
    - memory
    - network
execution:
- executor: jmeter" | tee -a node_mongo_getbyid_10.yml node_mongo_getbyid_100.yml node_mongo_patch_10.yml node_mongo_patch_100.yml node_mongo_delete_1.yml
echo "  concurrency: 10" | tee -a node_mongo_getbyid_10.yml node_mongo_patch_10.yml
echo "  concurrency: 100" | tee -a node_mongo_getbyid_100.yml node_mongo_patch_100.yml
echo "  concurrency: 1
  iterations: 1
  scenario:
    requests:" >> node_mongo_delete_1.yml
echo "  ramp-up: 1m
  hold-for: 2m
  scenario:
    requests:" | tee -a node_mongo_getbyid_10.yml node_mongo_getbyid_100.yml node_mongo_patch_10.yml node_mongo_patch_100.yml
curl http://node:3000/people | jq -r '"    - http://node:3000/people/\(.[].id)"' | tee -a node_mongo_getbyid_10.yml node_mongo_getbyid_100.yml
curl http://node:3000/people | jq -r --arg tail "
      method: PATCH
      headers:
        Content-Type: application/json
      body: '{\"firstName\": \"John\", \"lastName\": \"Smith\", \"email\": \"john.smith@email.com\"}'" '"    - url: http://node:3000/people/\(.[].id)\($tail)"' | tee -a node_mongo_patch_10.yml node_mongo_patch_100.yml
curl http://node:3000/people | jq -r --arg tail "
      method: DELETE" '"    - url: http://node:3000/people/\(.[].id)\($tail)"' | tee -a node_mongo_delete_1.yml
}

rm -r /tmp/artifacts

bzt node_mongo_plaintext_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_plaintext_10.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_plaintext_10.csv
bzt node_mongo_plaintext_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_plaintext_100.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_plaintext_100.csv
bzt node_mongo_plaintext_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_plaintext_1000.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_plaintext_1000.csv

bzt node_mongo_fibonacci_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_fibonacci_10.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_fibonacci_10.csv
bzt node_mongo_fibonacci_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_fibonacci_100.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_fibonacci_100.csv
bzt node_mongo_fibonacci_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_fibonacci_1000.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_fibonacci_1000.csv

bzt node_mongo_getall_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_getall_10.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_getall_10.csv
bzt node_mongo_getall_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_getall_100.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_getall_100.csv
bzt node_mongo_getall_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_getall_1000.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_getall_1000.csv

generate_configurations
bzt node_mongo_getbyid_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_getbyid_10.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_getbyid_10.csv
bzt node_mongo_getbyid_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_getbyid_100.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_getbyid_100.csv

bzt node_mongo_post_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_post_10.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_post_10.csv
curl -X POST http://node:3000/people/reset
bzt node_mongo_post_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_post_100.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_post_100.csv
curl -X POST http://node:3000/people/reset
bzt node_mongo_post_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_post_1000.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_post_1000.csv
curl -X POST http://node:3000/people/reset

generate_configurations
bzt node_mongo_patch_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_patch_10.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_patch_10.csv
curl -X POST http://node:3000/people/reset
generate_configurations
bzt node_mongo_patch_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_patch_100.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_patch_100.csv
curl -X POST http://node:3000/people/reset

generate_configurations
bzt node_mongo_delete_1.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_delete_1.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_delete_1.csv
curl -X POST http://node:3000/people/reset

for i in {1..10}
do

generate_configurations
bzt node_mongo_delete_1.yml
rm /tmp/artifacts/kpi.jtl
rm /tmp/artifacts/SAlogs_node_4444.csv
curl -X POST http://node:3000/people/reset

done

generate_configurations
bzt node_mongo_delete_1.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/node_mongo_delete_1.jtl
mv /tmp/artifacts/SAlogs_node_4444.csv /tmp/artifacts/node_mongo_delete_1.csv
curl -X POST http://node:3000/people/reset

now=$(date +"%m_%d_%Y_%H_%M_%S")
mv /tmp/artifacts "/tmp/artifacts_$now"
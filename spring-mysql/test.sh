#!/usr/bin/env bash
apt-get -y install jq

generate_configurations () {
> spring_mysql_getbyid_10.yml
> spring_mysql_getbyid_100.yml
> spring_mysql_patch_10.yml
> spring_mysql_patch_100.yml
> spring_mysql_delete_1.yml
echo "---
services:
- module: monitoring
  ^local:
  server-agent:
  - address: spring:4444
    logging: True
    metrics:
    - cpu
    - memory
    - network
execution:
- executor: jmeter" | tee -a spring_mysql_getbyid_10.yml spring_mysql_getbyid_100.yml spring_mysql_patch_10.yml spring_mysql_patch_100.yml spring_mysql_delete_1.yml
echo "  concurrency: 10" | tee -a spring_mysql_getbyid_10.yml spring_mysql_patch_10.yml
echo "  concurrency: 100" | tee -a spring_mysql_getbyid_100.yml spring_mysql_patch_100.yml
echo "  concurrency: 1
  iterations: 1
  scenario:
    requests:" >> spring_mysql_delete_1.yml
echo "  ramp-up: 1m
  hold-for: 2m
  scenario:
    requests:" | tee -a spring_mysql_getbyid_10.yml spring_mysql_getbyid_100.yml spring_mysql_patch_10.yml spring_mysql_patch_100.yml
curl http://spring:8080/people | jq -r '"    - http://spring:8080/people/\(.[].id)"' | tee -a spring_mysql_getbyid_10.yml spring_mysql_getbyid_100.yml
curl http://spring:8080/people | jq -r --arg tail "
      method: PATCH
      headers:
        Content-Type: application/json
      body: '{\"firstName\": \"John\", \"lastName\": \"Smith\", \"email\": \"john.smith@email.com\"}'" '"    - url: http://spring:8080/people/\(.[].id)\($tail)"' | tee -a spring_mysql_patch_10.yml spring_mysql_patch_100.yml
curl http://spring:8080/people | jq -r --arg tail "
      method: DELETE" '"    - url: http://spring:8080/people/\(.[].id)\($tail)"' | tee -a spring_mysql_delete_1.yml
}

rm -r /tmp/artifacts

bzt spring_mysql_plaintext_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_plaintext_10.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_plaintext_10.csv
bzt spring_mysql_plaintext_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_plaintext_100.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_plaintext_100.csv
bzt spring_mysql_plaintext_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_plaintext_1000.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_plaintext_1000.csv

bzt spring_mysql_fibonacci_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_fibonacci_10.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_fibonacci_10.csv
bzt spring_mysql_fibonacci_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_fibonacci_100.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_fibonacci_100.csv
bzt spring_mysql_fibonacci_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_fibonacci_1000.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_fibonacci_1000.csv

bzt spring_mysql_getall_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_getall_10.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_getall_10.csv
bzt spring_mysql_getall_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_getall_100.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_getall_100.csv
bzt spring_mysql_getall_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_getall_1000.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_getall_1000.csv

generate_configurations
bzt spring_mysql_getbyid_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_getbyid_10.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_getbyid_10.csv
bzt spring_mysql_getbyid_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_getbyid_100.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_getbyid_100.csv

bzt spring_mysql_post_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_post_10.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_post_10.csv
curl -X POST http://spring:8080/people/reset
bzt spring_mysql_post_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_post_100.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_post_100.csv
curl -X POST http://spring:8080/people/reset
bzt spring_mysql_post_1000.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_post_1000.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_post_1000.csv
curl -X POST http://spring:8080/people/reset

generate_configurations
bzt spring_mysql_patch_10.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_patch_10.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_patch_10.csv
curl -X POST http://spring:8080/people/reset
generate_configurations
bzt spring_mysql_patch_100.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_patch_100.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_patch_100.csv
curl -X POST http://spring:8080/people/reset

generate_configurations
bzt spring_mysql_delete_1.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_delete_1.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_delete_1.csv
curl -X POST http://spring:8080/people/reset

for i in {1..10}
do

generate_configurations
bzt spring_mysql_delete_1.yml
rm /tmp/artifacts/kpi.jtl
rm /tmp/artifacts/SAlogs_spring_4444.csv
curl -X POST http://spring:8080/people/reset

done

generate_configurations
bzt spring_mysql_delete_1.yml
mv /tmp/artifacts/kpi.jtl /tmp/artifacts/spring_mysql_delete_1.jtl
mv /tmp/artifacts/SAlogs_spring_4444.csv /tmp/artifacts/spring_mysql_delete_1.csv
curl -X POST http://spring:8080/people/reset

now=$(date +"%m_%d_%Y_%H_%M_%S")
mv /tmp/artifacts "/tmp/artifacts_$now"
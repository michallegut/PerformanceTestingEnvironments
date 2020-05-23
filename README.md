# Introduction

This repository contains four performance testing environments based on Taurus (with JMeter executor and ServerAgent) and Docker:

1. Node.js with Express and Cluster + MongoDB
2. Node.js with Express and Cluster + MySQL
3. Spring Boot + MongoDB
4. Spring Boot + MySQL

Application, database and Taurus are run in separate containers.

# Data

Databases contain one table with 1000 documents/records of the following structure:

## MongoDB
```
{
  "firstName": "Noah",
  "lastName": "Johnson",
  "email": "noah.johnson@email.com"
}
```

## MySQL
```
CREATE TABLE people
(
    id         VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(255),
    last_name  VARCHAR(255),
    email      VARCHAR(255)
);
INSERT INTO people (id, first_name, last_name, email)
VALUES (UUID(), 'Noah', 'Johnson', 'noah.johnson@email.com');
```

Databases are initialized and filled with data on container startup. They use ```data.sql``` and ```data.js``` files as a data source.

# Test methods

Each application has the same set of test methods:

Method | Description
------------ | -------------
plaintext() | Returns static text fragment with the lenght of 749 characters
fibonacci(n) | Calculates n-th Fibonacci number
getall() | Retrives all documents/records from the database
getbyid(id) | Retrives a document/record with the given id from the database
post(json) | Adds a document/record defined in the given JSON to the database
patch(id, json) | Modifies a document/record with the given id, according to the given JSON
delete(id) | Deletes a document/record with the given id from the database

# Metrics

The environment measures basic set of JMeter metrics and system resources usage metrics with ServerAgent. These most notably include:

* latency
* CPU usage
* memory usage

# Test cases

Each test case is a combination of test method and a number of concurrent virtual users. Test cases last 3 minutes including 1 minute ramp up. ```delete(id)``` method is an exception and it ends when all documents/records are deleted.

Method | 1 | 10 | 100 | 1000
------------ | ------------- | ------------- | ------------- | -------------
plaintext() |  | X | X | X
fibonacci(10000) |  | X | X | X
getall() |  | X | X | X
getbyid(id) |  | X | X |  
post(json) |  | X | X | X
patch(id, json) |  | X | X |  
delete(id) | X |   |   |  

As can be seen each method is tested with 10, 100 and 1000 concurrent users except ```getbyid(id)``` and ```patch(id, json)``` which are tested with 10 and 100 users, and ```delete(id)``` which is tested with only 1 user.  
```fibonacci(n)``` method always calculates 10000th Fibonacci number.  
Test cases are defined in YML files.

# Test run script

Test run script atomates execution of the test run. It's tasks are:

* Running test cases
* Reseting database after a modification
* Generating tests cases' configuration files with new UUIDs after a database reset
* JIT warm up before delete method because it lacks ramp up
* Saving results

Database is reseted using a HTTP request to the appliactions which take care of reinitialization of the data.  
Results are saved to ```results/artifacts_DD_MM_YYYY_hh_mm_ss``` directory as JTL and CSV files named after test cases.  
The test run script is defined in ```test.sh``` file.  
There is also a ```transfer.sh``` script which automatically compresses and uploads results to transfer.sh file hosting.

# Usage

Performance tests can be run on a network of Docker Swarm machines or on a single machine using Docker Compose.

## Docker Swarm

Docker Swarm is a preferred method because it allows to split the load that each component generates on many machines.

1. Run ```swarm init --advertise-addr=<IP-ADDRESS-OF-MANAGER>``` on the swarm manager machine. It will return a token
2. Run ```docker swarm join --token <TOKEN> <IP-ADDRESS-OF-MANAGER>:2377``` on every worker
3. Clone this repository and download missing files described in the next section (only for Node.js environments) on the manager and every worker
4. Move to the chosen environment directory on the manager
5. Run ```docker stack deploy --compose-file docker-compose.yml test-environment``` on the manager
6. To display list of services run ```docker service ls``` on the manager
7. To check which machine is running a service and check it's state run ```docker service ps test-environment_<SERVICE-NAME>``` on the manager
8. To display logs from a service run ```run docker service logs --follow test-environment_<SERVICE-NAME>``` on the manager
9. When you gather enough results ```run chmod u+x transfer.sh``` (only on Linux) and ```./transfer.sh``` on the machine running Taurus. It will upload results and return a download link. Results can also be accessed manually as described in the previous section

## Docker Compose

To run the test environment on a single machine Docker Compose can be used. Before running the environment resources limits for every container should be set in ```docker-compose.yml``` file. It would work without it but Taurus and database would affect application's performance.

1. Clone this repository and download missing files described in the next section (only for Node.js environments)
2. Move to the chosen environment directory
3. Run ```docker-compose up```. It will automatically display logs from every container
4. When you gather enough results ```run chmod u+x transfer.sh``` (only on Linux) and ```./transfer.sh``` on the machine running Taurus. It will upload results and return a download link. Results can also be accessed manually as described in the previous section

# Missing files

Due to GitHub 100 MB size limit few files from Node.js environments are missing from the repository and have to be downloaded:

## JDK
1. Download latest verion of JDK and insert it into ```node-mongo/ServerAgent-2.2.3``` and ```node-mysql/ServerAgent-2.2.3``` directories
2. Edit ```node-mongo/ServerAgent-2.2.3/startAgent.sh``` and ```node-mysql/ServerAgent-2.2.3/startAgent.sh``` to use downloaded JDK

## node_modules
1. Download and install Node.js
2. Run ```npm install``` in ```node-mongo/node-mongo-performance``` and ```node-mongo/node-mysql-performance``` directories

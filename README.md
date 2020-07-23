# Mongoose

Mongoose is a [Cloudstate](https://github.com/cloudstateio/cloudstate) proxy implementation.

## Overview

Mongoose takes advantage of Elixir's simplicity and elegance, mainly because we know the power of Erlang's basic components, such as the features of Beam VM, the OTP structure and the libraries established by the Elixir community, such as Broadway, Libcluster, Horde and Ecto to build a highly efficient, resilient and low memory usage Cloudstate proxy.

## Features

- [x] Cluster transparent
- [ ] Cloudstate Entity Types:
    - [ ] Actions (Stateless Support)
    - [ ] CRDT's
    - [ ] EventSourced Support
        - [ ] Multi Node Forward and Side Effects
    - [ ] KV
- [x] Discovery Support
- [ ] Eventing:
    - [ ] Amazon SQS
    - [ ] Apache Kafka
    - [ ] Cloud Pub/Sub
    - [ ] Event Log
    - [ ] RabbitMQ
    - [ ] Redis
- [ ] Interoperability with Cloudstate reference implementation
- [ ] Metadata Support
- [ ] Metrics Support
- [ ] State Store:
    - [ ] Cassandra
    - [ ] In Memory
    - [ ] MongoDB
    - [ ] MSSQL
    - [ ] MySql
    - [ ] Postgres
    - [ ] Redis
    - [ ] Riak
- [x] Transports and Protocols
    - [ ] GRPC
        - [x] Client TCP
        - [x] Client Unix Domain Sockets
        - [ ] Server TCP 
    - [ ] HTTP 
        - [ ] SSE
        - [ ] Websockets
- [x] Very Fast
- [ ] TCK

## Inversion of State

TODO

# Massa

Massa is a Massive Serverless Systems Architecture.

Relax this is just an internal joke. The name Massa is due to a river near the Eigr mountain in Switzerland.

Now seriously Massa is just [CloudState](https://github.com/cloudstateio/cloudstate) proxy implementation build on top of BEAM/Elixir

## Overview

Massa takes advantage of Elixir's simplicity and elegance, mainly because we know the power of Erlang's basic components, such as the features of Beam VM, the OTP structure and the libraries established by the Elixir community, such as Broadway, Libcluster, Horde and Ecto to build a highly efficient, resilient and low memory usage Cloudstate proxy.

## Features

- [ ] ARM Support
- [ ] Cloudstate Entity Types:
    - [ ] Actions (Stateless Support)
    - [ ] CRDT's
    - [ ] EventSourced Support
        - [ ] Multi Node Forward and Side Effects
    - [ ] KV
- [x] Cluster transparent
- [x] Discovery Support
- [ ] Eventing
- [x] Interoperability with Cloudstate reference implementation
- [ ] Metadata Support
- [x] Observability:
    - [x] Health Checks
    - [x] Metrics
    - [x] Open Tracing
- [ ] State Store:
    - [ ] In Memory
    - [ ] Mnesia
    - [ ] Cassandra
    - [ ] MongoDB
    - [ ] MSSQL
    - [ ] MySql
    - [ ] Postgres
- [ ] TCK
- [x] Transports and Protocols
    - [x] GRPC
        - [x] Client TCP
        - [x] Client Unix Domain Sockets
        - [ ] Reflection
        - [ ] Server TCP 
    - [ ] HTTP

## Main Concepts

TODO

## Inversion of State

TODO

## Benchmark

TODO
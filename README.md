# Massa

Massa is a Massive Serverless Systems Architecture.

Relax this is just an internal joke. The name Massa is due to a river near the Eigr mountain in Switzerland.

Now seriously Massa is just [CloudState](https://github.com/cloudstateio/cloudstate) proxy implementation build on top of BEAM/Elixir

## Overview

Massa is Cloudstate Sidecar Proxy implemented on top of Erlang BEAM VM.
We takes advantage of Elixir's simplicity and elegance, mainly because we know the power of Erlang's basic components, such as the features of Beam VM, the OTP structure and the libraries established by the Elixir community, such as Broadway, Libcluster, Horde and Ecto to build a highly efficient, resilient and low memory usage Cloudstate proxy.

## Main Concepts

TODO

## Inversion of State

TODO

## Project Status

- [x] Compliance implementation of Cloudstate Protocol
- [x] Automatic Cluster formation
- [x] Transports and Protocols
    - [x] GRPC:
        - [x] TCP Server
        - [x] Unix Domain Sockets (Proxy -> UserFunction)
        - [x] [Reflection](https://github.com/grpc/grpc/blob/master/doc/server-reflection.md) (grpcurl support)
        - [ ] TLS Support
    - [ ] [HTTP Transcoding](https://cloud.google.com/endpoints/docs/grpc/transcoding)
- [x] Observability:
    - [x] Health Checks
    - [x] Metrics
    - [x] Open Tracing
- [ ] Entity State Active Caching
- [x] Cloudstate Protocol Features:
    - [x] Discovery Support
    - [x] Actions (Stateless Support):
        - [x] Unary Requests
        - [ ] Streamed Requests
        - [ ] StreamIn Requests
        - [ ] StreamOut Requests
        - [ ] Multi Node Forward and Side Effects
    - [ ] Value Entities
    - [ ] EventSourced Support:
        - [ ] Multi Node Forward and Side Effects
        - [ ] Projections
    - [ ] CRDT's
    - [ ] Eventing
        - [ ] Amazon SQS
        - [ ] Apache Kafka
        - [ ] Google PubSub
        - [ ] RabbitMQ
    - [ ] Metadata Support
- [ ] Massa Specific or Extensions Features:
    - [ ] Multi Node Forward and Side Effects (proxy-to-proxy communication)
    - [ ] External Remote Forward and Side Effects (proxy-to-outside communication)
    - [ ] GraphQL Transcoding
- [ ] State Stores:
    - [ ] Mnesia (InMemory/File)
    - [ ] [EventStore](https://www.eventstore.com)
    - [ ] Postgres
- [ ] TCK
- [x] Platforms & Architectures:
    - [x] x86 Support
    - [ ] ARM Support
    - [x] Kubernetes
    - [ ] [Knative](https://knative.dev)
    - [x] [Docker Swarm](https://docs.docker.com/engine/swarm/) (with [Podlike](https://github.com/rycus86/podlike))

## Benchmark

TODO
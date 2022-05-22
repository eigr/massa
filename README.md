# Massa

<sub>(The name Massa is due to a river near the Eiger mountain in Switzerland)</sub>

[Massa](https://github.com/eigr/massa/blob/main/FAQ.md#faq) is a Sidecar proxy part of the Eigr Functions offering that aims to provide a high-level abstraction for Stateful Serveless application development.

The Massa proxy is responsible for managing the entire data access infrastructure for user functions, as well as other technical tasks, such as providing the implementation of the user contract via gRPC to the outside world, transcoding HTTP requests to gRPV, caching, making requests to external sources when requested and other tasks that would once have to be performed by the developer directly in his application.

With Massa, the developer only has to worry about their domain objects and their user interface via a contract-first declarative approach.

## Overview

Massa is a Sidecar Proxy implemented on top of Erlang BEAM VM.

We takes advantage of Elixir's simplicity and elegance, mainly because we know the power of Erlang's basic components, such as the features of Beam VM, the OTP structure and the libraries established by the Elixir community, such as Broadway, Libcluster, Horde and Ecto to build a highly efficient, resilient and low memory usage proxy.

## Main Concepts

Eigr functions is composed of the following components:

* A Kubernetes controller that acts as a control plane orchestrating deployments of PODs composed of User Roles and Sidecar Proxy.

* A proxy that acts as a data plane to forward user traffic to user functions, as well as provide the entire infrastructure for handling statestores and the like. The proxy communicates with the user role via specific runtime implementations which may actually be interfaced via gRPC communication or in the future via the Wasm interface.

* The user role that implements a series of rules defined by the Eigr Functions protocol and that allows the user to develop their applications in a way that focuses only on their business domain objects.

Below is a general diagram of all these components:

```raw
╔════════════════════════════════════════════════╗
║                  ╔═════════════════════════════╣
║                  ║            Proxy            ║
║                  ║                             ║
║                  ║                             ║
║                  ║       State Management      ║
║                  ╠═════════════════════════════╣
║                  ║            Proxy            ║
║                  ║                             ║
║                  ║                             ║
║                  ║           runtime           ║
║                  ╠═════════════════════════════╣
║                  ║        Language SDKs        ║
║                  ║                             ║
║                  ║ (eigr/functions-python-sdk) ║
║                  ╠═════════════════════════════╣
║                  ║         Deployment          ║
║                  ║                             ║
║                  ║   eigr/functions-operator   ║
║eigr/functions    ╚═════════════════════════════╣
╚════════════════════════════════════════════════╝

```

The flow of information is as follows:

```
                               ┌─────────┐                 ┌─────────┐                    
                         ┌────▶│PORT 9001│            ┌───▶│ Runtime │                    
╔════════════════════╗   │    ╔╩─────────╩═════════╗  │   ╔╩─────────╩═══════════════════════╗
║                    ║   │    ║                    ║  │   ║      User Function App           ║
║     grpc client    ╠───┘    ║  eigr/massa proxy  ╠──┘   ║                                  ║
║                    ║        ║                    ║      ║  gcr.io/eigr-io/eigr-go-example  ║
╚════════════════════╝        ╚════════════════════╝      ╚══════════════════════════════════╝
```

That is, a client message arriving via gRPC or HTTP is handled by the proxy which then activates the internal process that reflects to the User Function and its state and forwards the request to the User Function. This in turn handles the request and may or may not update the entity's state, returning a response to the Proxy.
In turn, the proxy updates the entity's state in the Statestore and forwards the final response to the calling client.

The User Function can also choose to forward the request to be handled by another function, which we call **Forwards** or **Effects** (depending on the expected behavior), or even perform an direct **Invocation** on another entity to compose its request handling logic. This is all done transparently by the proxy with idiomatic APIs being provided to user roles via the SDKs.

In Eigr either Forwards, Effects or Invocations can be performed for any entities registered in the cluster (or even for entities remote from the cluster in the future). This is done transparently through the Distributed Erlang stack itself without exposing the User Function to any communication infrastructure needed to perform these actions.

```
╔═══════════════╗                             ╔═══════════════╗
║               ║─┐                        ┌─▶║               ║
║  Message In   ║ │  ╔═══════════════════╗ │  ║  Message Out  ║
║               ║ └─▶║                   ║─┘  ║               ║
╚═══════════════╝    ║      Service      ║    ╚═══════════════╝
╔═══════════════╗ ┌─▶║                   ║─┐  ╔═══════════════╗
║               ║ │  ╚═══════════════════╝ │  ║               ║
║   State In    ║─┘                        └─▶║   State Out   ║
║               ║                             ║               ║
╚═══════════════╝                             ╚═══════════════╝
```

## Inversion of State

State is brought to the incoming message right at the time the message passed to the service and even before the service handles that message. This is possible by state-models that are abstracted in a way so that state can be lifted to a context available to a service that has chosen the very state-model.

```
                                                 ┌ ─ ─ ─ ─ ─ ─ ─ ─                                      
                   ╔═════════════════════════╗       message-in   │                                     
                   ║                         ║   │                                                      
╔════════════╗     ║                         ║     ╔════════════╗ │                                     
║  request1  ║─────╬──(1)────────────────────╬──▶│ ║  request1  ║─────(3.2)────────────┐                
╚════════════╝     ║                         ║     ╠════════════╣ │                    │                
                   ║             ┌─────(2)───╬──▶│ ║   state1   ║─────(3.1)──────┐     │                
                   ║             │           ║     ╚════════════╝ │              │     │                
                   ║             │           ║   └ ─ ─ ─ ─ ─ ─ ─ ─   ╔════════════════╬═════╬═══════════════╗
                   ║             │           ║                       ║           │     │                    ║
                   ║             │           ║                       ║           ▼     ▼                    ║
                   ║             │           ║                       ║ user_function(ctx, message) response ║
                   ║             │           ║                       ║                                      ║
                   ║             │           ║                       ║           │               │          ║
                   ║             │           ║   ┌ ─ ─ ─ ─ ─ ─ ─ ─   ╚═══════════╬═══════════════╬══════════╝
╔════════════╗     ║             │           ║     ╔════════════╗ │              │               │      
║ response1  ║◀────╬──(6)────────┼───────────╬───┼─║ response1  ║  ◀──(4.2)──────┼───────────────┘      
╚════════════╝     ║             │           ║     ╠════════════╣ │              │                      
                   ║             │    ┌──────╬───┼─║   state2   ║  ◀──(4.1)──────┘                      
                   ║             │    │      ║     ╚════════════╝ │                                     
                   ║Proxy        │    │      ║   │                                                      
                   ╚═════════════╬════╬══════╝      message-out   │                                     
                                 │    │          └ ─ ─ ─ ─ ─ ─ ─ ─                                      
                                 │    │                                                                 
                                 │    │                                                                 
                   ╔═════════════╬════╬══════╗                                                          
                   ║             │    │      ║                                                          
                   ║             │    │      ║     ╔════════════╗                                       
                   ║             └────┼──────╬─────║   state1   ║                                       
                   ║                  │      ║     ╠════════════╣                                       
                   ║                  └─(5)──╬────▶║   state2   ║                                       
                   ║                         ║     ╚════════════╝                                       
                   ║State-Management         ║                                                          
                   ╚═════════════════════════╝                                                                                                                    
```

In the Eigr sidecar proxy, it's actually hosting erlang Process to represent these user functions. 

The user call the sidecar then the sidecar connects via Runtime abstraction (gRPC or Wasm**) to the actual deployed user functions. The resulting data goes into the statestore. It could be read from the statestore, which is shared across the left and the right sides whenever needed.

In turn, the support library and the user function are responsible for managing the data locally in memory. Think of it as a multilevel cache, where the same data lives in the user function, in Sidecar's Active Process memory, and in the database. Data will be accessed from hot sources in most cases and this will ensure superior read performance and delivered to the user function.

The fact that the user does not have any direct interaction with the database allows the proxy to perform a series of optimizations on this data, and also ensures that the data will always be close to the user function that responds to a request.

** In development

## Programming Language Agnostic programming model

TODO

## Project Status

- [x] Automatic Cluster formation
- [x] Runtimes:
    - [x] gRPC
    - [ ] Wasm
- [x] Transports and Protocols
    - [x] GRPC:
        - [x] TCP
        - [x] UDS (Unix Domain Sockets)
        - [x] [Reflection](https://github.com/grpc/grpc/blob/master/doc/server-reflection.md) ([grpcurl](https://github.com/fullstorydev/grpcurl) support)
        - [x] TLS Support
    - [ ] [HTTP Transcoding](https://cloud.google.com/endpoints/docs/grpc/transcoding)
- [x] Observability:
    - [x] Health Checks
    - [x] Metrics
    - [x] Open Tracing
- [x] Protocol Features:
    - [x] Discovery Support
    - [x] Actions (Stateless Support):
        - [x] Unary Requests
        - [x] Streamed Requests
        - [x] StreamIn Requests
        - [x] StreamOut Requests
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
- [ ] Massa Specific or Extensions Features:
    - [x] Multi Node Forward and Side Effects (proxy-to-proxy communication)
    - [ ] External Remote Forward and Side Effects (proxy-to-outside communication)
    - [ ] Keda Integration
- [ ] State Stores:
    - [ ] [EventStore](https://www.eventstore.com)
    - [ ] InMemory
    - [ ] MySQL
    - [ ] Postgres
- [ ] TCK

## Benchmark

TODO

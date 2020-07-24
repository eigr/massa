#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# CloudState Protocol
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/cloudstate/entity_key.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/entity.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/event_sourced.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/function.proto

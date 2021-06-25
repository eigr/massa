#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# CloudState Protocol

protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/proxy/ priv/protos/proxy/grpc/reflection/v1alpha/reflection.proto

protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/google/api/http.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/google/api/annotations.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/google/api/httpbody.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/google/api/auth.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/google/api/source_info.proto

protoc --elixir_out=gen_descriptors=true:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/cloudstate/eventing.proto
protoc --elixir_out=gen_descriptors=true:./lib --proto_path=priv/protos/frontend/ priv/protos/frontend/cloudstate/entity_key.proto

protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/entity.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/event_sourced.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/action.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/protocol/ priv/protos/protocol/cloudstate/value_entity.proto

#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# CloudState Protocol

protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/eigr/functions/proxy/ priv/protos/eigr/functions/proxy/grpc/reflection/v1alpha/reflection.proto

protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/eigr/functions/frontend/ priv/protos/eigr/functions/frontend/google/api/http.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/eigr/functions/frontend/ priv/protos/eigr/functions/frontend/google/api/annotations.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/eigr/functions/frontend/ priv/protos/eigr/functions/frontend/google/api/httpbody.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/eigr/functions/frontend/ priv/protos/eigr/functions/frontend/google/api/auth.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib --proto_path=priv/protos/eigr/functions/frontend/ priv/protos/eigr/functions/frontend/google/api/source_info.proto

protoc --elixir_out=gen_descriptors=true:./lib/eigr/functions/protocol --proto_path=priv/protos/eigr/functions/protocol/eigr/ priv/protos/eigr/functions/protocol/eigr/eventing.proto
protoc --elixir_out=gen_descriptors=true:./lib/eigr/functions/protocol --proto_path=priv/protos/eigr/functions/protocol/eigr/ priv/protos/eigr/functions/protocol/eigr/entity_key.proto

protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib/eigr/functions/protocol --proto_path=priv/protos/eigr/functions/protocol/eigr/ priv/protos/eigr/functions/protocol/eigr/entity.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib/eigr/functions/protocol --proto_path=priv/protos/eigr/functions/protocol/eigr/ priv/protos/eigr/functions/protocol/eigr/event_sourced.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib/eigr/functions/protocol --proto_path=priv/protos/eigr/functions/protocol/eigr/ priv/protos/eigr/functions/protocol/eigr/action.proto
protoc --elixir_out=gen_descriptors=true,plugins=grpc:./lib/eigr/functions/protocol --proto_path=priv/protos/eigr/functions/protocol/eigr/ priv/protos/eigr/functions/protocol/eigr/value_entity.proto

defmodule MassaProxy.Server do
  require Logger

  alias Protobuf.Protoc.Context
  alias Protobuf.Protoc.Generator.Extension, as: Generator

  def start(descriptors, entities) do
    descriptors
    |> compile

    # TODO: Create grpc ==> entities |> generate_services |> generate_endpoint |> start_proxy
  end

  defp compile(descriptors) do
    # ctx = %Context{global_type_mapping: %{"name.proto" => %{}}}
    # desc = Google.Protobuf.FileDescriptorProto.new(name: "name.proto")
    descriptors
    |> Flow.from_enumerable()
    |> Flow.filter(&skip_cloudstate_type/1)
    |> Flow.filter(&skip_well_known_type/1)
  end

  defp generate_services(entities) do
    # TODO compile templates with entities infos
    # Ex.: EEx.eval_file(
    #         "apps/massa_proxy/priv/templates/grpc_service.ex.eex",
    #         [
    #            mod_name: "ShoppingCart",
    #            name: "Com.Example.Shoppingcart.Service",
    #            methods: ["getCart"],
    #            handler: "Massa.EventSourced.Handler"]
    #          ]
    #      )
    #
    # Then compile string module into Elixir code
    # And finally
    # return the services to create grpc endpoint
    #
    # services
  end

  defp generate_services(services) do
    # Ex.: EEx.eval_file(
    #         "apps/massa_proxy/priv/templates/grpc_endpoint.ex.eex",
    #         [
    #            services: services.names
    #          ]
    #      )
  end

  defp start_proxy(args) do
  end

  defp skip_cloudstate_type(descriptor),
    do:
      !Enum.member?(["cloudstate/entity_key.proto", "cloudstate/eventing.proto"], descriptor.name)

  defp skip_well_known_type(descriptor),
    do:
      !Enum.member?(
        [
          "google/protobuf/any.proto",
          "google/protobuf/empty.proto",
          "google/protobuf/timestamp.proto",
          "google/protobuf/struct.proto",
          "google/protobuf/duration.proto",
          "google/api/http.proto",
          "google/api/httpbody.proto",
          "google/api/annotations.proto",
          "google/api/auth.proto",
          "google/api/source_info.proto"
        ],
        descriptor.name
      )
end
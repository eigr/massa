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
end

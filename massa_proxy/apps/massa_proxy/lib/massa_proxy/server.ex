defmodule MassaProxy.Server do
  @moduledoc false
  require Logger

  alias Protobuf.Protoc.Context
  alias Protobuf.Protoc.Generator.Util
  alias Protobuf.Protoc.Generator.Message, as: Generator

  @grpc_template_path Path.expand("./templates/grpc_service.ex.eex", :code.priv_dir(:massa_proxy))

  def start(descriptors, entities) do
    descriptors
    |> compile

    generate_services(entities)

    # TODO: Create grpc ==> entities |> generate_services |> generate_endpoint |> start_proxy
  end

  defp compile(descriptors) do
    d = %{name: nil, dependencies: [], descriptor: nil, ctx: nil}

    files =
      descriptors
      |> MassaProxy.Reflection.compile()

    for file <- files do
      Logger.info("Compiling module: #{inspect(file)}")
      result = Code.eval_string(file)
      Logger.debug("Compiled module: #{inspect(result)}")
    end
  end

  defp normalize_service_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
  end

  defp normalize_mehod_name(name), do: Macro.underscore(name)

  defp generate_services(entities) do

    for entity <- entities do
      name = Enum.join([normalize_service_name(entity.service_name), "Service"], ".")
      services = Enum.at(entity.services, 0) |> Enum.at(0)
      methods =
        services.methods
        |> Flow.from_enumerable()
        |> Flow.map(&normalize_mehod_name(&1.name))
        |> Enum.to_list()

      Logger.info("Generating Service #{name} with Methods: #{inspect methods}")
      mod =
        EEx.eval_file(
          @grpc_template_path,
          mod_name: name,
          name: name,
          methods: methods,
          handler: "Massa.EventSourced.Handler"
        )

      Logger.info("Service defined: #{mod}")
      mod_compiled = Code.eval_string(mod)
      Logger.info("Service compiled: #{inspect mod_compiled}")
    end

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
          "google/protobuf/descriptor.proto",
          "google/api/http.proto",
          "google/api/httpbody.proto",
          "google/api/annotations.proto",
          "google/api/auth.proto",
          "google/api/source_info.proto"
        ],
        descriptor.name
      )
end

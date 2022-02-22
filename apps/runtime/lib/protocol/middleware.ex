defmodule Runtime.Protocol.Middleware do
  @doc """
  Middleware is a bridge between the protocol and the user function.
  The main purpose of middleware is to provide a way to add some abstraction between
  the underlying transport, user function and the Entity processor.

  The main responsibility of this module's callbacks is to abstract the transport, that is,
  the communication channel with the user role.
  Processing rules should not be performed by the implementations of this module's callbacks.
  """
  @type state :: any()
  @type reason :: any()

  @callback do_init(state) ::
              {:ok, state}
              | {:ok, state, timeout() | :hibernate | {:continue, term()}}
              | :ignore
              | {:stop, reason :: any()}

  @callback handle_effect(any()) :: {:ok, any()} | {:error, any()}

  @callback handle_forward(any(), any()) :: {:ok, any()} | {:error, any()}

  @callback handle_unary(any(), any()) :: {:ok, any()} | {:error, any()}

  @callback handle_streamed(any(), any()) :: {:ok, Stream.t()} | {:error, any()}

  @callback handle_stream_in(any(), Stream.t()) :: {:ok, any()} | {:error, any()}

  @callback handle_stream_out(any(), any()) :: {:ok, Stream.t()} | {:error, any()}

  def do_init(state), do: {:ok, state, :hibernate}

  def handle_effect(_context) do
    raise "Not implemented"
  end

  def handle_forward(_context, _message) do
    raise "Not implemented"
  end

  def handle_unary(_context, _message) do
    raise "Not implemented"
  end

  def handle_streamed(_context, _messages) do
    raise "Not implemented"
  end

  def handle_stream_in(_context, _messages) do
    raise "Not implemented"
  end

  def handle_stream_out(_context, _message) do
    raise "Not implemented"
  end

  defoverridable do_init: 1,
                 handle_effect: 1,
                 handle_forward: 2,
                 handle_unary: 2,
                 handle_streamed: 2,
                 handle_stream_in: 2,
                 handle_stream_out: 2

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Runtime.Protocol.Middleware
      use GenServer

      require Logger

      alias Cloudstate.{Action.ActionResponse, SideEffect}
      alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient
      alias Runtime.Protocol.Router
      alias MassaProxy.Runtime.Grpc.Protocol.Action.Protocol, as: ActionProtocol

      alias Runtime

      @command_processor opts[:command_processor]

      def start_link(%{name: name} = state) do
        GenServer.start_link(__MODULE__, state, name: name)
      end

      @impl true
      def init(state) do
        do_init(state)
      end

      @impl true
      def handle_call(
            {:handle_unary, %{context: context, payload: message} = _input},
            _from,
            state
          ) do
        result =
          with {:ok, %{side_effects: effects} = command} <- handle_unary(context, message),
               {:ok, result} <- @command_processor.apply(context, command) do
            call_effects(context, effects)
            {:ok, result}
          else
            {:error, reason} -> {:error, "Failure to make unary request #{inspect(reason)}"}
          end

        Logger.debug("Middleware User function response #{inspect(result)}")

        {:reply, result, state}
      end

      @impl true
      def handle_call(
            {:handle_streamed, %{context: context, payload: messages} = _input},
            from,
            state
          ) do
        spawn(fn ->
          stream_result =
            with {:ok, consumer_stream} <- handle_streamed(context, messages) do
              consumer_stream =
                consumer_stream
                |> Stream.map(fn
                  {:ok, %{side_effects: effects} = command} ->
                    Logger.debug("Consumer Stream result: #{inspect(command)}")

                    result =
                      case @command_processor.apply(context, command) do
                        {:ok, result} ->
                          {:ok, result}

                        {:error, reason} ->
                          {:error, "Failure on process command #{inspect(reason)}"}
                      end

                    call_effects(context, effects)
                    result

                  {:error, reason} ->
                    {:error, "Failure on process client stream #{inspect(reason)}"}
                end)
                |> Enum.to_list()

              {:ok, consumer_stream}
            else
              {:ok, []} ->
                {:error, "Client not returned a stream"}

              {:error, reason} ->
                {:error, reason}
            end

          GenServer.reply(from, stream_result)
        end)

        {:noreply, state}
      end

      @impl true
      def handle_cast({:handle_effect, context}, state) do
        with {:ok, %{side_effects: effects} = command} <- handle_effect(context),
             {:ok, result} <- @command_processor.apply(context, command) do
          Logger.debug(
            "Handle effects User function response #{inspect(command)}. With commands result #{inspect(result)}"
          )

          call_effects(context, effects)
        else
          {:error, reason} ->
            Logger.warn("Failure to make unary request #{inspect(reason)}")
        end

        {:noreply, state}
      end

      defp call_effects(_ctx, []), do: {:ok, []}

      defp call_effects(
             %{entity_type: entity_type} = _ctx,
             effects
           )
           when is_list(effects) and length(effects) > 0 do
        Enum.each(effects, fn %SideEffect{
                                service_name: service_name,
                                command_name: command_name,
                                synchronous: synchronous,
                                payload: %Google.Protobuf.Any{type_url: input_type} = payload
                              } = effect ->
          Logger.debug(
            "Handling side effect #{inspect(effect)}} with command name: #{command_name} and input type: #{input_type}"
          )

          message = %{
            message: payload,
            entity_type: nil,
            service_name: nil,
            request_type: nil,
            original_method: nil,
            input_type: nil,
            output_type: nil,
            persistence_id: nil,
            stream: nil
          }

          Router.route(
            entity_type,
            service_name,
            command_name,
            input_type,
            !synchronous,
            __MODULE__,
            :effect,
            message
          )
        end)
      end

      defp call_effects(_ctx, _), do: {:ok, []}

      # end quoted
    end

    # end defmacro
  end

  # Client API
  def unary(%{entity_type: entity_type} = ctx, message) do
    GenServer.call(get_name(entity_type), {:handle_unary, %{context: ctx, payload: message}})
  end

  def streamed(%{entity_type: entity_type} = ctx, messages) do
    GenServer.call(get_name(entity_type), {:handle_streamed, %{context: ctx, payload: messages}})
  end

  def effect(%{entity_type: entity_type} = ctx) do
    GenServer.cast(get_name(entity_type), {:handle_effect, ctx})
  end

  defp get_name(entity_type) do
    mod =
      entity_type
      |> String.split(".")
      |> Enum.at(-1)

    Module.concat(__MODULE__, mod)
  end
end

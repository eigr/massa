defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Protocol do
  alias Cloudstate.{Action.ActionCommand, Action.ActionResponse, Metadata}
  alias Google.Protobuf.Any
  alias MassaProxy.Util

  @type t :: map()
  @type command_type :: :payload | :metadata | :full

  @spec decode(t(), ActionReponse.t()) :: term()
  def decode(%{output_type: output_mod}, %ActionResponse{response: {_action, payload}}) do
    decode_payload(output_mod, payload)
  end

  @spec build_msg(t(), command_type()) :: ActionComand.t()
  def build_msg(ctx, command_type \\ :full)

  def build_msg(ctx, :full) do
    cmd = build_msg(ctx, :metadata)

    %{cmd | payload: build_payload(ctx)}
  end

  def build_msg(%{service_name: service_name, original_method: original_method}, :metadata) do
    ActionCommand.new(
      service_name: service_name,
      name: original_method,
      metadata: Metadata.new()
    )
  end

  def build_msg(ctx, :payload) do
    ActionCommand.new(payload: build_payload(ctx))
  end

  @spec build_stream(t()) :: Enumerable.t()
  def build_stream(%{message: msgs} = state) do
    # Need to signal end_of_stream so attach a token to
    # end of the stream so that we can call `GRPC.Stub.end_stream`
    msgs
    |> Stream.concat([:halt])
    |> Stream.transform({:pre_send, state}, &transform/2)
  end

  defp transform(:halt, _acc) do
    {[:halt], :halt}
  end

  defp transform(_msg, {:pre_send, state}) do
    command = build_msg(state, :metadata)

    {[command], {:sending, state}}
  end

  defp transform(msg, {:sending, state} = acc) do
    command = build_msg(%{state | message: msg}, :payload)
    {[command], acc}
  end

  defp build_payload(%{input_type: input_type, message: msg}),
    do:
      Any.new(
        type_url: Util.get_type_url(input_type),
        value: input_type.encode(msg)
      )

  defp decode_payload(output_mod, %{payload: %Any{value: bin}}), do: output_mod.decode(bin)
end

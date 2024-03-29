defmodule Cloudstate.Action.ActionCommand do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          name: String.t(),
          payload: Google.Protobuf.Any.t() | nil,
          metadata: Cloudstate.Metadata.t() | nil
        }

  defstruct [:service_name, :name, :payload, :metadata]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 13, 65, 99, 116, 105, 111, 110, 67, 111, 109, 109, 97, 110, 100, 18, 33, 10, 12, 115,
        101, 114, 118, 105, 99, 101, 95, 110, 97, 109, 101, 24, 2, 32, 1, 40, 9, 82, 11, 115, 101,
        114, 118, 105, 99, 101, 78, 97, 109, 101, 18, 18, 10, 4, 110, 97, 109, 101, 24, 3, 32, 1,
        40, 9, 82, 4, 110, 97, 109, 101, 18, 46, 10, 7, 112, 97, 121, 108, 111, 97, 100, 24, 4,
        32, 1, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98,
        117, 102, 46, 65, 110, 121, 82, 7, 112, 97, 121, 108, 111, 97, 100, 18, 48, 10, 8, 109,
        101, 116, 97, 100, 97, 116, 97, 24, 5, 32, 1, 40, 11, 50, 20, 46, 99, 108, 111, 117, 100,
        115, 116, 97, 116, 101, 46, 77, 101, 116, 97, 100, 97, 116, 97, 82, 8, 109, 101, 116, 97,
        100, 97, 116, 97>>
    )
  end

  field(:service_name, 2, type: :string)
  field(:name, 3, type: :string)
  field(:payload, 4, type: Google.Protobuf.Any)
  field(:metadata, 5, type: Cloudstate.Metadata)
end

defmodule Cloudstate.Action.ActionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          response: {atom, any},
          side_effects: [Cloudstate.SideEffect.t()]
        }

  defstruct [:response, :side_effects]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 14, 65, 99, 116, 105, 111, 110, 82, 101, 115, 112, 111, 110, 115, 101, 18, 47, 10, 7,
        102, 97, 105, 108, 117, 114, 101, 24, 1, 32, 1, 40, 11, 50, 19, 46, 99, 108, 111, 117,
        100, 115, 116, 97, 116, 101, 46, 70, 97, 105, 108, 117, 114, 101, 72, 0, 82, 7, 102, 97,
        105, 108, 117, 114, 101, 18, 41, 10, 5, 114, 101, 112, 108, 121, 24, 2, 32, 1, 40, 11, 50,
        17, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 82, 101, 112, 108, 121, 72, 0,
        82, 5, 114, 101, 112, 108, 121, 18, 47, 10, 7, 102, 111, 114, 119, 97, 114, 100, 24, 3,
        32, 1, 40, 11, 50, 19, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 70, 111,
        114, 119, 97, 114, 100, 72, 0, 82, 7, 102, 111, 114, 119, 97, 114, 100, 18, 57, 10, 12,
        115, 105, 100, 101, 95, 101, 102, 102, 101, 99, 116, 115, 24, 4, 32, 3, 40, 11, 50, 22,
        46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 83, 105, 100, 101, 69, 102, 102,
        101, 99, 116, 82, 11, 115, 105, 100, 101, 69, 102, 102, 101, 99, 116, 115, 66, 10, 10, 8,
        114, 101, 115, 112, 111, 110, 115, 101>>
    )
  end

  oneof(:response, 0)

  field(:failure, 1, type: Cloudstate.Failure, oneof: 0)
  field(:reply, 2, type: Cloudstate.Reply, oneof: 0)
  field(:forward, 3, type: Cloudstate.Forward, oneof: 0)
  field(:side_effects, 4, repeated: true, type: Cloudstate.SideEffect)
end

defmodule Cloudstate.Action.ActionProtocol.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.action.ActionProtocol"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 14, 65, 99, 116, 105, 111, 110, 80, 114, 111, 116, 111, 99, 111, 108, 18, 91, 10, 11,
        104, 97, 110, 100, 108, 101, 85, 110, 97, 114, 121, 18, 32, 46, 99, 108, 111, 117, 100,
        115, 116, 97, 116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110,
        67, 111, 109, 109, 97, 110, 100, 26, 33, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116,
        101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 82, 101, 115, 112,
        111, 110, 115, 101, 34, 3, 136, 2, 0, 40, 0, 48, 0, 18, 96, 10, 16, 104, 97, 110, 100,
        108, 101, 83, 116, 114, 101, 97, 109, 101, 100, 73, 110, 18, 32, 46, 99, 108, 111, 117,
        100, 115, 116, 97, 116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111,
        110, 67, 111, 109, 109, 97, 110, 100, 26, 33, 46, 99, 108, 111, 117, 100, 115, 116, 97,
        116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 82, 101, 115,
        112, 111, 110, 115, 101, 34, 3, 136, 2, 0, 40, 1, 48, 0, 18, 97, 10, 17, 104, 97, 110,
        100, 108, 101, 83, 116, 114, 101, 97, 109, 101, 100, 79, 117, 116, 18, 32, 46, 99, 108,
        111, 117, 100, 115, 116, 97, 116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116,
        105, 111, 110, 67, 111, 109, 109, 97, 110, 100, 26, 33, 46, 99, 108, 111, 117, 100, 115,
        116, 97, 116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 82,
        101, 115, 112, 111, 110, 115, 101, 34, 3, 136, 2, 0, 40, 0, 48, 1, 18, 94, 10, 14, 104,
        97, 110, 100, 108, 101, 83, 116, 114, 101, 97, 109, 101, 100, 18, 32, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105,
        111, 110, 67, 111, 109, 109, 97, 110, 100, 26, 33, 46, 99, 108, 111, 117, 100, 115, 116,
        97, 116, 101, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 82, 101,
        115, 112, 111, 110, 115, 101, 34, 3, 136, 2, 0, 40, 1, 48, 1>>
    )
  end

  rpc(:handleUnary, Cloudstate.Action.ActionCommand, Cloudstate.Action.ActionResponse)

  rpc(
    :handleStreamedIn,
    stream(Cloudstate.Action.ActionCommand),
    Cloudstate.Action.ActionResponse
  )

  rpc(
    :handleStreamedOut,
    Cloudstate.Action.ActionCommand,
    stream(Cloudstate.Action.ActionResponse)
  )

  rpc(
    :handleStreamed,
    stream(Cloudstate.Action.ActionCommand),
    stream(Cloudstate.Action.ActionResponse)
  )
end

defmodule Cloudstate.Action.ActionProtocol.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.Action.ActionProtocol.Service
end

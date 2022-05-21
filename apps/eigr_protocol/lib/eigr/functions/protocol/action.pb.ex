defmodule Eigr.Functions.Protocol.Action.ActionCommand do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          name: String.t(),
          payload: Google.Protobuf.Any.t() | nil,
          metadata: Eigr.Functions.Protocol.Metadata.t() | nil
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
        117, 102, 46, 65, 110, 121, 82, 7, 112, 97, 121, 108, 111, 97, 100, 18, 61, 10, 8, 109,
        101, 116, 97, 100, 97, 116, 97, 24, 5, 32, 1, 40, 11, 50, 33, 46, 101, 105, 103, 114, 46,
        102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108, 46,
        77, 101, 116, 97, 100, 97, 116, 97, 82, 8, 109, 101, 116, 97, 100, 97, 116, 97>>
    )
  end

  field :service_name, 2, type: :string
  field :name, 3, type: :string
  field :payload, 4, type: Google.Protobuf.Any
  field :metadata, 5, type: Eigr.Functions.Protocol.Metadata
end

defmodule Eigr.Functions.Protocol.Action.ActionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          response: {atom, any},
          side_effects: [Eigr.Functions.Protocol.SideEffect.t()]
        }
  defstruct [:response, :side_effects]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 14, 65, 99, 116, 105, 111, 110, 82, 101, 115, 112, 111, 110, 115, 101, 18, 60, 10, 7,
        102, 97, 105, 108, 117, 114, 101, 24, 1, 32, 1, 40, 11, 50, 32, 46, 101, 105, 103, 114,
        46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108,
        46, 70, 97, 105, 108, 117, 114, 101, 72, 0, 82, 7, 102, 97, 105, 108, 117, 114, 101, 18,
        54, 10, 5, 114, 101, 112, 108, 121, 24, 2, 32, 1, 40, 11, 50, 30, 46, 101, 105, 103, 114,
        46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108,
        46, 82, 101, 112, 108, 121, 72, 0, 82, 5, 114, 101, 112, 108, 121, 18, 60, 10, 7, 102,
        111, 114, 119, 97, 114, 100, 24, 3, 32, 1, 40, 11, 50, 32, 46, 101, 105, 103, 114, 46,
        102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108, 46,
        70, 111, 114, 119, 97, 114, 100, 72, 0, 82, 7, 102, 111, 114, 119, 97, 114, 100, 18, 70,
        10, 12, 115, 105, 100, 101, 95, 101, 102, 102, 101, 99, 116, 115, 24, 4, 32, 3, 40, 11,
        50, 35, 46, 101, 105, 103, 114, 46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112,
        114, 111, 116, 111, 99, 111, 108, 46, 83, 105, 100, 101, 69, 102, 102, 101, 99, 116, 82,
        11, 115, 105, 100, 101, 69, 102, 102, 101, 99, 116, 115, 66, 10, 10, 8, 114, 101, 115,
        112, 111, 110, 115, 101>>
    )
  end

  oneof :response, 0
  field :failure, 1, type: Eigr.Functions.Protocol.Failure, oneof: 0
  field :reply, 2, type: Eigr.Functions.Protocol.Reply, oneof: 0
  field :forward, 3, type: Eigr.Functions.Protocol.Forward, oneof: 0
  field :side_effects, 4, repeated: true, type: Eigr.Functions.Protocol.SideEffect
end

defmodule Eigr.Functions.Protocol.Action.ActionProtocol.Service do
  @moduledoc false
  use GRPC.Service, name: "eigr.functions.protocol.action.ActionProtocol"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 14, 65, 99, 116, 105, 111, 110, 80, 114, 111, 116, 111, 99, 111, 108, 18, 117, 10, 11,
        104, 97, 110, 100, 108, 101, 85, 110, 97, 114, 121, 18, 45, 46, 101, 105, 103, 114, 46,
        102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108, 46,
        97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 67, 111, 109, 109, 97, 110,
        100, 26, 46, 46, 101, 105, 103, 114, 46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46,
        112, 114, 111, 116, 111, 99, 111, 108, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116,
        105, 111, 110, 82, 101, 115, 112, 111, 110, 115, 101, 34, 3, 136, 2, 0, 40, 0, 48, 0, 18,
        122, 10, 16, 104, 97, 110, 100, 108, 101, 83, 116, 114, 101, 97, 109, 101, 100, 73, 110,
        18, 45, 46, 101, 105, 103, 114, 46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112,
        114, 111, 116, 111, 99, 111, 108, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105,
        111, 110, 67, 111, 109, 109, 97, 110, 100, 26, 46, 46, 101, 105, 103, 114, 46, 102, 117,
        110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108, 46, 97, 99,
        116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 82, 101, 115, 112, 111, 110, 115, 101,
        34, 3, 136, 2, 0, 40, 1, 48, 0, 18, 123, 10, 17, 104, 97, 110, 100, 108, 101, 83, 116,
        114, 101, 97, 109, 101, 100, 79, 117, 116, 18, 45, 46, 101, 105, 103, 114, 46, 102, 117,
        110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108, 46, 97, 99,
        116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 67, 111, 109, 109, 97, 110, 100, 26,
        46, 46, 101, 105, 103, 114, 46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114,
        111, 116, 111, 99, 111, 108, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111,
        110, 82, 101, 115, 112, 111, 110, 115, 101, 34, 3, 136, 2, 0, 40, 0, 48, 1, 18, 120, 10,
        14, 104, 97, 110, 100, 108, 101, 83, 116, 114, 101, 97, 109, 101, 100, 18, 45, 46, 101,
        105, 103, 114, 46, 102, 117, 110, 99, 116, 105, 111, 110, 115, 46, 112, 114, 111, 116,
        111, 99, 111, 108, 46, 97, 99, 116, 105, 111, 110, 46, 65, 99, 116, 105, 111, 110, 67,
        111, 109, 109, 97, 110, 100, 26, 46, 46, 101, 105, 103, 114, 46, 102, 117, 110, 99, 116,
        105, 111, 110, 115, 46, 112, 114, 111, 116, 111, 99, 111, 108, 46, 97, 99, 116, 105, 111,
        110, 46, 65, 99, 116, 105, 111, 110, 82, 101, 115, 112, 111, 110, 115, 101, 34, 3, 136, 2,
        0, 40, 1, 48, 1>>
    )
  end

  rpc :handleUnary,
      Eigr.Functions.Protocol.Action.ActionCommand,
      Eigr.Functions.Protocol.Action.ActionResponse

  rpc :handleStreamedIn,
      stream(Eigr.Functions.Protocol.Action.ActionCommand),
      Eigr.Functions.Protocol.Action.ActionResponse

  rpc :handleStreamedOut,
      Eigr.Functions.Protocol.Action.ActionCommand,
      stream(Eigr.Functions.Protocol.Action.ActionResponse)

  rpc :handleStreamed,
      stream(Eigr.Functions.Protocol.Action.ActionCommand),
      stream(Eigr.Functions.Protocol.Action.ActionResponse)
end

defmodule Eigr.Functions.Protocol.Action.ActionProtocol.Stub do
  @moduledoc false
  use GRPC.Stub, service: Eigr.Functions.Protocol.Action.ActionProtocol.Service
end

defmodule Cloudstate.Valueentity.ValueEntityStreamIn do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 19, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 83, 116, 114, 101, 97, 109,
        73, 110, 18, 61, 10, 4, 105, 110, 105, 116, 24, 1, 32, 1, 40, 11, 50, 39, 46, 99, 108,
        111, 117, 100, 115, 116, 97, 116, 101, 46, 118, 97, 108, 117, 101, 101, 110, 116, 105,
        116, 121, 46, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 73, 110, 105, 116, 72,
        0, 82, 4, 105, 110, 105, 116, 18, 47, 10, 7, 99, 111, 109, 109, 97, 110, 100, 24, 2, 32,
        1, 40, 11, 50, 19, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 67, 111, 109,
        109, 97, 110, 100, 72, 0, 82, 7, 99, 111, 109, 109, 97, 110, 100, 66, 9, 10, 7, 109, 101,
        115, 115, 97, 103, 101>>
    )
  end

  oneof(:message, 0)
  field(:init, 1, type: Cloudstate.Valueentity.ValueEntityInit, oneof: 0)
  field(:command, 2, type: Cloudstate.Command, oneof: 0)
end

defmodule Cloudstate.Valueentity.ValueEntityInit do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          entity_id: String.t(),
          state: Cloudstate.Valueentity.ValueEntityInitState.t() | nil
        }

  defstruct [:service_name, :entity_id, :state]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 15, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 73, 110, 105, 116, 18, 33, 10,
        12, 115, 101, 114, 118, 105, 99, 101, 95, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9, 82, 11,
        115, 101, 114, 118, 105, 99, 101, 78, 97, 109, 101, 18, 27, 10, 9, 101, 110, 116, 105,
        116, 121, 95, 105, 100, 24, 2, 32, 1, 40, 9, 82, 8, 101, 110, 116, 105, 116, 121, 73, 100,
        18, 66, 10, 5, 115, 116, 97, 116, 101, 24, 3, 32, 1, 40, 11, 50, 44, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 118, 97, 108, 117, 101, 101, 110, 116, 105, 116,
        121, 46, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 73, 110, 105, 116, 83, 116,
        97, 116, 101, 82, 5, 115, 116, 97, 116, 101>>
    )
  end

  field(:service_name, 1, type: :string)
  field(:entity_id, 2, type: :string)
  field(:state, 3, type: Cloudstate.Valueentity.ValueEntityInitState)
end

defmodule Cloudstate.Valueentity.ValueEntityInitState do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: Google.Protobuf.Any.t() | nil
        }

  defstruct [:value]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 20, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 73, 110, 105, 116, 83, 116,
        97, 116, 101, 18, 42, 10, 5, 118, 97, 108, 117, 101, 24, 1, 32, 1, 40, 11, 50, 20, 46,
        103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121,
        82, 5, 118, 97, 108, 117, 101>>
    )
  end

  field(:value, 1, type: Google.Protobuf.Any)
end

defmodule Cloudstate.Valueentity.ValueEntityStreamOut do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 20, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 83, 116, 114, 101, 97, 109,
        79, 117, 116, 18, 64, 10, 5, 114, 101, 112, 108, 121, 24, 1, 32, 1, 40, 11, 50, 40, 46,
        99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 118, 97, 108, 117, 101, 101, 110, 116,
        105, 116, 121, 46, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 82, 101, 112, 108,
        121, 72, 0, 82, 5, 114, 101, 112, 108, 121, 18, 47, 10, 7, 102, 97, 105, 108, 117, 114,
        101, 24, 2, 32, 1, 40, 11, 50, 19, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46,
        70, 97, 105, 108, 117, 114, 101, 72, 0, 82, 7, 102, 97, 105, 108, 117, 114, 101, 66, 9,
        10, 7, 109, 101, 115, 115, 97, 103, 101>>
    )
  end

  oneof(:message, 0)
  field(:reply, 1, type: Cloudstate.Valueentity.ValueEntityReply, oneof: 0)
  field(:failure, 2, type: Cloudstate.Failure, oneof: 0)
end

defmodule Cloudstate.Valueentity.ValueEntityReply do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          command_id: integer,
          client_action: Cloudstate.ClientAction.t() | nil,
          side_effects: [Cloudstate.SideEffect.t()],
          state_action: Cloudstate.Valueentity.ValueEntityAction.t() | nil
        }

  defstruct [:command_id, :client_action, :side_effects, :state_action]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 16, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 82, 101, 112, 108, 121, 18,
        29, 10, 10, 99, 111, 109, 109, 97, 110, 100, 95, 105, 100, 24, 1, 32, 1, 40, 3, 82, 9, 99,
        111, 109, 109, 97, 110, 100, 73, 100, 18, 61, 10, 13, 99, 108, 105, 101, 110, 116, 95, 97,
        99, 116, 105, 111, 110, 24, 2, 32, 1, 40, 11, 50, 24, 46, 99, 108, 111, 117, 100, 115,
        116, 97, 116, 101, 46, 67, 108, 105, 101, 110, 116, 65, 99, 116, 105, 111, 110, 82, 12,
        99, 108, 105, 101, 110, 116, 65, 99, 116, 105, 111, 110, 18, 57, 10, 12, 115, 105, 100,
        101, 95, 101, 102, 102, 101, 99, 116, 115, 24, 3, 32, 3, 40, 11, 50, 22, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 83, 105, 100, 101, 69, 102, 102, 101, 99, 116, 82,
        11, 115, 105, 100, 101, 69, 102, 102, 101, 99, 116, 115, 18, 76, 10, 12, 115, 116, 97,
        116, 101, 95, 97, 99, 116, 105, 111, 110, 24, 4, 32, 1, 40, 11, 50, 41, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 118, 97, 108, 117, 101, 101, 110, 116, 105, 116,
        121, 46, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 65, 99, 116, 105, 111, 110,
        82, 11, 115, 116, 97, 116, 101, 65, 99, 116, 105, 111, 110>>
    )
  end

  field(:command_id, 1, type: :int64)
  field(:client_action, 2, type: Cloudstate.ClientAction)
  field(:side_effects, 3, repeated: true, type: Cloudstate.SideEffect)
  field(:state_action, 4, type: Cloudstate.Valueentity.ValueEntityAction)
end

defmodule Cloudstate.Valueentity.ValueEntityAction do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          action: {atom, any}
        }

  defstruct [:action]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 65, 99, 116, 105, 111, 110,
        18, 67, 10, 6, 117, 112, 100, 97, 116, 101, 24, 1, 32, 1, 40, 11, 50, 41, 46, 99, 108,
        111, 117, 100, 115, 116, 97, 116, 101, 46, 118, 97, 108, 117, 101, 101, 110, 116, 105,
        116, 121, 46, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 85, 112, 100, 97, 116,
        101, 72, 0, 82, 6, 117, 112, 100, 97, 116, 101, 18, 67, 10, 6, 100, 101, 108, 101, 116,
        101, 24, 2, 32, 1, 40, 11, 50, 41, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46,
        118, 97, 108, 117, 101, 101, 110, 116, 105, 116, 121, 46, 86, 97, 108, 117, 101, 69, 110,
        116, 105, 116, 121, 68, 101, 108, 101, 116, 101, 72, 0, 82, 6, 100, 101, 108, 101, 116,
        101, 66, 8, 10, 6, 97, 99, 116, 105, 111, 110>>
    )
  end

  oneof(:action, 0)
  field(:update, 1, type: Cloudstate.Valueentity.ValueEntityUpdate, oneof: 0)
  field(:delete, 2, type: Cloudstate.Valueentity.ValueEntityDelete, oneof: 0)
end

defmodule Cloudstate.Valueentity.ValueEntityUpdate do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: Google.Protobuf.Any.t() | nil
        }

  defstruct [:value]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 85, 112, 100, 97, 116, 101,
        18, 42, 10, 5, 118, 97, 108, 117, 101, 24, 1, 32, 1, 40, 11, 50, 20, 46, 103, 111, 111,
        103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121, 82, 5, 118,
        97, 108, 117, 101>>
    )
  end

  field(:value, 1, type: Google.Protobuf.Any)
end

defmodule Cloudstate.Valueentity.ValueEntityDelete do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 68, 101, 108, 101, 116, 101>>
    )
  end
end

defmodule Cloudstate.Valueentity.ValueEntity.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.valueentity.ValueEntity"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 11, 86, 97, 108, 117, 101, 69, 110, 116, 105, 116, 121, 18, 108, 10, 6, 104, 97, 110,
        100, 108, 101, 18, 43, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 118, 97,
        108, 117, 101, 101, 110, 116, 105, 116, 121, 46, 86, 97, 108, 117, 101, 69, 110, 116, 105,
        116, 121, 83, 116, 114, 101, 97, 109, 73, 110, 26, 44, 46, 99, 108, 111, 117, 100, 115,
        116, 97, 116, 101, 46, 118, 97, 108, 117, 101, 101, 110, 116, 105, 116, 121, 46, 86, 97,
        108, 117, 101, 69, 110, 116, 105, 116, 121, 83, 116, 114, 101, 97, 109, 79, 117, 116, 34,
        3, 136, 2, 0, 40, 1, 48, 1>>
    )
  end

  rpc(
    :handle,
    stream(Cloudstate.Valueentity.ValueEntityStreamIn),
    stream(Cloudstate.Valueentity.ValueEntityStreamOut)
  )
end

defmodule Cloudstate.Valueentity.ValueEntity.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.Valueentity.ValueEntity.Service
end

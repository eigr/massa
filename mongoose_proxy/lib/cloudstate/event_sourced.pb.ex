defmodule Cloudstate.Eventsourced.EventSourcedInit do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          entity_id: String.t(),
          snapshot: Cloudstate.Eventsourced.EventSourcedSnapshot.t() | nil
        }

  defstruct [:service_name, :entity_id, :snapshot]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 16, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 73, 110, 105, 116, 18,
        33, 10, 12, 115, 101, 114, 118, 105, 99, 101, 95, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9,
        82, 11, 115, 101, 114, 118, 105, 99, 101, 78, 97, 109, 101, 18, 27, 10, 9, 101, 110, 116,
        105, 116, 121, 95, 105, 100, 24, 2, 32, 1, 40, 9, 82, 8, 101, 110, 116, 105, 116, 121, 73,
        100, 18, 73, 10, 8, 115, 110, 97, 112, 115, 104, 111, 116, 24, 3, 32, 1, 40, 11, 50, 45,
        46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 101, 118, 101, 110, 116, 115, 111,
        117, 114, 99, 101, 100, 46, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 83,
        110, 97, 112, 115, 104, 111, 116, 82, 8, 115, 110, 97, 112, 115, 104, 111, 116>>
    )
  end

  field :service_name, 1, type: :string
  field :entity_id, 2, type: :string
  field :snapshot, 3, type: Cloudstate.Eventsourced.EventSourcedSnapshot
end

defmodule Cloudstate.Eventsourced.EventSourcedSnapshot do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          snapshot_sequence: integer,
          snapshot: Google.Protobuf.Any.t() | nil
        }

  defstruct [:snapshot_sequence, :snapshot]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 20, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 83, 110, 97, 112, 115,
        104, 111, 116, 18, 43, 10, 17, 115, 110, 97, 112, 115, 104, 111, 116, 95, 115, 101, 113,
        117, 101, 110, 99, 101, 24, 1, 32, 1, 40, 3, 82, 16, 115, 110, 97, 112, 115, 104, 111,
        116, 83, 101, 113, 117, 101, 110, 99, 101, 18, 48, 10, 8, 115, 110, 97, 112, 115, 104,
        111, 116, 24, 2, 32, 1, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112, 114,
        111, 116, 111, 98, 117, 102, 46, 65, 110, 121, 82, 8, 115, 110, 97, 112, 115, 104, 111,
        116>>
    )
  end

  field :snapshot_sequence, 1, type: :int64
  field :snapshot, 2, type: Google.Protobuf.Any
end

defmodule Cloudstate.Eventsourced.EventSourcedEvent do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          sequence: integer,
          payload: Google.Protobuf.Any.t() | nil
        }

  defstruct [:sequence, :payload]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 69, 118, 101, 110, 116,
        18, 26, 10, 8, 115, 101, 113, 117, 101, 110, 99, 101, 24, 1, 32, 1, 40, 3, 82, 8, 115,
        101, 113, 117, 101, 110, 99, 101, 18, 46, 10, 7, 112, 97, 121, 108, 111, 97, 100, 24, 2,
        32, 1, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98,
        117, 102, 46, 65, 110, 121, 82, 7, 112, 97, 121, 108, 111, 97, 100>>
    )
  end

  field :sequence, 1, type: :int64
  field :payload, 2, type: Google.Protobuf.Any
end

defmodule Cloudstate.Eventsourced.EventSourcedReply do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          command_id: integer,
          client_action: Cloudstate.ClientAction.t() | nil,
          side_effects: [Cloudstate.SideEffect.t()],
          events: [Google.Protobuf.Any.t()],
          snapshot: Google.Protobuf.Any.t() | nil
        }

  defstruct [:command_id, :client_action, :side_effects, :events, :snapshot]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 82, 101, 112, 108, 121,
        18, 29, 10, 10, 99, 111, 109, 109, 97, 110, 100, 95, 105, 100, 24, 1, 32, 1, 40, 3, 82, 9,
        99, 111, 109, 109, 97, 110, 100, 73, 100, 18, 61, 10, 13, 99, 108, 105, 101, 110, 116, 95,
        97, 99, 116, 105, 111, 110, 24, 2, 32, 1, 40, 11, 50, 24, 46, 99, 108, 111, 117, 100, 115,
        116, 97, 116, 101, 46, 67, 108, 105, 101, 110, 116, 65, 99, 116, 105, 111, 110, 82, 12,
        99, 108, 105, 101, 110, 116, 65, 99, 116, 105, 111, 110, 18, 57, 10, 12, 115, 105, 100,
        101, 95, 101, 102, 102, 101, 99, 116, 115, 24, 3, 32, 3, 40, 11, 50, 22, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 83, 105, 100, 101, 69, 102, 102, 101, 99, 116, 82,
        11, 115, 105, 100, 101, 69, 102, 102, 101, 99, 116, 115, 18, 44, 10, 6, 101, 118, 101,
        110, 116, 115, 24, 4, 32, 3, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112,
        114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121, 82, 6, 101, 118, 101, 110, 116, 115,
        18, 48, 10, 8, 115, 110, 97, 112, 115, 104, 111, 116, 24, 5, 32, 1, 40, 11, 50, 20, 46,
        103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121,
        82, 8, 115, 110, 97, 112, 115, 104, 111, 116>>
    )
  end

  field :command_id, 1, type: :int64
  field :client_action, 2, type: Cloudstate.ClientAction
  field :side_effects, 3, repeated: true, type: Cloudstate.SideEffect
  field :events, 4, repeated: true, type: Google.Protobuf.Any
  field :snapshot, 5, type: Google.Protobuf.Any
end

defmodule Cloudstate.Eventsourced.EventSourcedStreamIn do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 20, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 83, 116, 114, 101, 97,
        109, 73, 110, 18, 63, 10, 4, 105, 110, 105, 116, 24, 1, 32, 1, 40, 11, 50, 41, 46, 99,
        108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 101, 118, 101, 110, 116, 115, 111, 117,
        114, 99, 101, 100, 46, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 73, 110,
        105, 116, 72, 0, 82, 4, 105, 110, 105, 116, 18, 66, 10, 5, 101, 118, 101, 110, 116, 24, 2,
        32, 1, 40, 11, 50, 42, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 101, 118,
        101, 110, 116, 115, 111, 117, 114, 99, 101, 100, 46, 69, 118, 101, 110, 116, 83, 111, 117,
        114, 99, 101, 100, 69, 118, 101, 110, 116, 72, 0, 82, 5, 101, 118, 101, 110, 116, 18, 47,
        10, 7, 99, 111, 109, 109, 97, 110, 100, 24, 3, 32, 1, 40, 11, 50, 19, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 67, 111, 109, 109, 97, 110, 100, 72, 0, 82, 7, 99,
        111, 109, 109, 97, 110, 100, 66, 9, 10, 7, 109, 101, 115, 115, 97, 103, 101>>
    )
  end

  oneof :message, 0
  field :init, 1, type: Cloudstate.Eventsourced.EventSourcedInit, oneof: 0
  field :event, 2, type: Cloudstate.Eventsourced.EventSourcedEvent, oneof: 0
  field :command, 3, type: Cloudstate.Command, oneof: 0
end

defmodule Cloudstate.Eventsourced.EventSourcedStreamOut do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 21, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 83, 116, 114, 101, 97,
        109, 79, 117, 116, 18, 66, 10, 5, 114, 101, 112, 108, 121, 24, 1, 32, 1, 40, 11, 50, 42,
        46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 101, 118, 101, 110, 116, 115, 111,
        117, 114, 99, 101, 100, 46, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 82,
        101, 112, 108, 121, 72, 0, 82, 5, 114, 101, 112, 108, 121, 18, 47, 10, 7, 102, 97, 105,
        108, 117, 114, 101, 24, 2, 32, 1, 40, 11, 50, 19, 46, 99, 108, 111, 117, 100, 115, 116,
        97, 116, 101, 46, 70, 97, 105, 108, 117, 114, 101, 72, 0, 82, 7, 102, 97, 105, 108, 117,
        114, 101, 66, 9, 10, 7, 109, 101, 115, 115, 97, 103, 101>>
    )
  end

  oneof :message, 0
  field :reply, 1, type: Cloudstate.Eventsourced.EventSourcedReply, oneof: 0
  field :failure, 2, type: Cloudstate.Failure, oneof: 0
end

defmodule Cloudstate.Eventsourced.EventSourced.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.eventsourced.EventSourced"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 12, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 18, 112, 10, 6, 104, 97,
        110, 100, 108, 101, 18, 45, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 101,
        118, 101, 110, 116, 115, 111, 117, 114, 99, 101, 100, 46, 69, 118, 101, 110, 116, 83, 111,
        117, 114, 99, 101, 100, 83, 116, 114, 101, 97, 109, 73, 110, 26, 46, 46, 99, 108, 111,
        117, 100, 115, 116, 97, 116, 101, 46, 101, 118, 101, 110, 116, 115, 111, 117, 114, 99,
        101, 100, 46, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 100, 83, 116, 114, 101,
        97, 109, 79, 117, 116, 34, 3, 136, 2, 0, 40, 1, 48, 1>>
    )
  end

  rpc :handle,
      stream(Cloudstate.Eventsourced.EventSourcedStreamIn),
      stream(Cloudstate.Eventsourced.EventSourcedStreamOut)
end

defmodule Cloudstate.Eventsourced.EventSourced.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.Eventsourced.EventSourced.Service
end

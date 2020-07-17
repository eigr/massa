defmodule Cloudstate.Eventsourced.EventSourcedInit do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          entity_id: String.t(),
          snapshot: Cloudstate.Eventsourced.EventSourcedSnapshot.t() | nil
        }

  defstruct [:service_name, :entity_id, :snapshot]

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

  oneof :message, 0
  field :reply, 1, type: Cloudstate.Eventsourced.EventSourcedReply, oneof: 0
  field :failure, 2, type: Cloudstate.Failure, oneof: 0
end

defmodule Cloudstate.Eventsourced.EventSourced.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.eventsourced.EventSourced"

  rpc :handle,
      stream(Cloudstate.Eventsourced.EventSourcedStreamIn),
      stream(Cloudstate.Eventsourced.EventSourcedStreamOut)
end

defmodule Cloudstate.Eventsourced.EventSourced.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.Eventsourced.EventSourced.Service
end

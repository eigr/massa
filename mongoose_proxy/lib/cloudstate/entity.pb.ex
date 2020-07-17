defmodule Cloudstate.Reply do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          payload: Google.Protobuf.Any.t() | nil
        }

  defstruct [:payload]

  field(:payload, 1, type: Google.Protobuf.Any)
end

defmodule Cloudstate.Forward do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          command_name: String.t(),
          payload: Google.Protobuf.Any.t() | nil
        }

  defstruct [:service_name, :command_name, :payload]

  field(:service_name, 1, type: :string)
  field(:command_name, 2, type: :string)
  field(:payload, 3, type: Google.Protobuf.Any)
end

defmodule Cloudstate.ClientAction do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          action: {atom, any}
        }

  defstruct [:action]

  oneof(:action, 0)
  field(:reply, 1, type: Cloudstate.Reply, oneof: 0)
  field(:forward, 2, type: Cloudstate.Forward, oneof: 0)
  field(:failure, 3, type: Cloudstate.Failure, oneof: 0)
end

defmodule Cloudstate.SideEffect do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          command_name: String.t(),
          payload: Google.Protobuf.Any.t() | nil,
          synchronous: boolean
        }

  defstruct [:service_name, :command_name, :payload, :synchronous]

  field(:service_name, 1, type: :string)
  field(:command_name, 2, type: :string)
  field(:payload, 3, type: Google.Protobuf.Any)
  field(:synchronous, 4, type: :bool)
end

defmodule Cloudstate.Command do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          entity_id: String.t(),
          id: integer,
          name: String.t(),
          payload: Google.Protobuf.Any.t() | nil,
          streamed: boolean
        }

  defstruct [:entity_id, :id, :name, :payload, :streamed]

  field(:entity_id, 1, type: :string)
  field(:id, 2, type: :int64)
  field(:name, 3, type: :string)
  field(:payload, 4, type: Google.Protobuf.Any)
  field(:streamed, 5, type: :bool)
end

defmodule Cloudstate.StreamCancelled do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          entity_id: String.t(),
          id: integer
        }

  defstruct [:entity_id, :id]

  field(:entity_id, 1, type: :string)
  field(:id, 2, type: :int64)
end

defmodule Cloudstate.Failure do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          command_id: integer,
          description: String.t()
        }

  defstruct [:command_id, :description]

  field(:command_id, 1, type: :int64)
  field(:description, 2, type: :string)
end

defmodule Cloudstate.EntitySpec do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          proto: binary,
          entities: [Cloudstate.Entity.t()],
          service_info: Cloudstate.ServiceInfo.t() | nil
        }

  defstruct [:proto, :entities, :service_info]

  field(:proto, 1, type: :bytes)
  field(:entities, 2, repeated: true, type: Cloudstate.Entity)
  field(:service_info, 3, type: Cloudstate.ServiceInfo)
end

defmodule Cloudstate.ServiceInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          service_version: String.t(),
          service_runtime: String.t(),
          support_library_name: String.t(),
          support_library_version: String.t()
        }

  defstruct [
    :service_name,
    :service_version,
    :service_runtime,
    :support_library_name,
    :support_library_version
  ]

  field(:service_name, 1, type: :string)
  field(:service_version, 2, type: :string)
  field(:service_runtime, 3, type: :string)
  field(:support_library_name, 4, type: :string)
  field(:support_library_version, 5, type: :string)
end

defmodule Cloudstate.Entity do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          entity_type: String.t(),
          service_name: String.t(),
          persistence_id: String.t()
        }

  defstruct [:entity_type, :service_name, :persistence_id]

  field(:entity_type, 1, type: :string)
  field(:service_name, 2, type: :string)
  field(:persistence_id, 3, type: :string)
end

defmodule Cloudstate.UserFunctionError do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: String.t()
        }

  defstruct [:message]

  field(:message, 1, type: :string)
end

defmodule Cloudstate.ProxyInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          protocol_major_version: integer,
          protocol_minor_version: integer,
          proxy_name: String.t(),
          proxy_version: String.t(),
          supported_entity_types: [String.t()]
        }

  defstruct [
    :protocol_major_version,
    :protocol_minor_version,
    :proxy_name,
    :proxy_version,
    :supported_entity_types
  ]

  field(:protocol_major_version, 1, type: :int32)
  field(:protocol_minor_version, 2, type: :int32)
  field(:proxy_name, 3, type: :string)
  field(:proxy_version, 4, type: :string)
  field(:supported_entity_types, 5, repeated: true, type: :string)
end

defmodule Cloudstate.EntityDiscovery.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.EntityDiscovery"

  rpc(:discover, Cloudstate.ProxyInfo, Cloudstate.EntitySpec)

  rpc(:reportError, Cloudstate.UserFunctionError, Google.Protobuf.Empty)
end

defmodule Cloudstate.EntityDiscovery.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.EntityDiscovery.Service
end

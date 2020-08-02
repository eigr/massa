defmodule Cloudstate.Reply do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          payload: Google.Protobuf.Any.t() | nil
        }

  defstruct [:payload]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 5, 82, 101, 112, 108, 121, 18, 46, 10, 7, 112, 97, 121, 108, 111, 97, 100, 24, 1, 32,
        1, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117,
        102, 46, 65, 110, 121, 82, 7, 112, 97, 121, 108, 111, 97, 100>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 7, 70, 111, 114, 119, 97, 114, 100, 18, 33, 10, 12, 115, 101, 114, 118, 105, 99, 101,
        95, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9, 82, 11, 115, 101, 114, 118, 105, 99, 101, 78,
        97, 109, 101, 18, 33, 10, 12, 99, 111, 109, 109, 97, 110, 100, 95, 110, 97, 109, 101, 24,
        2, 32, 1, 40, 9, 82, 11, 99, 111, 109, 109, 97, 110, 100, 78, 97, 109, 101, 18, 46, 10, 7,
        112, 97, 121, 108, 111, 97, 100, 24, 3, 32, 1, 40, 11, 50, 20, 46, 103, 111, 111, 103,
        108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121, 82, 7, 112, 97,
        121, 108, 111, 97, 100>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 12, 67, 108, 105, 101, 110, 116, 65, 99, 116, 105, 111, 110, 18, 41, 10, 5, 114, 101,
        112, 108, 121, 24, 1, 32, 1, 40, 11, 50, 17, 46, 99, 108, 111, 117, 100, 115, 116, 97,
        116, 101, 46, 82, 101, 112, 108, 121, 72, 0, 82, 5, 114, 101, 112, 108, 121, 18, 47, 10,
        7, 102, 111, 114, 119, 97, 114, 100, 24, 2, 32, 1, 40, 11, 50, 19, 46, 99, 108, 111, 117,
        100, 115, 116, 97, 116, 101, 46, 70, 111, 114, 119, 97, 114, 100, 72, 0, 82, 7, 102, 111,
        114, 119, 97, 114, 100, 18, 47, 10, 7, 102, 97, 105, 108, 117, 114, 101, 24, 3, 32, 1, 40,
        11, 50, 19, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 70, 97, 105, 108, 117,
        114, 101, 72, 0, 82, 7, 102, 97, 105, 108, 117, 114, 101, 66, 8, 10, 6, 97, 99, 116, 105,
        111, 110>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 10, 83, 105, 100, 101, 69, 102, 102, 101, 99, 116, 18, 33, 10, 12, 115, 101, 114, 118,
        105, 99, 101, 95, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9, 82, 11, 115, 101, 114, 118, 105,
        99, 101, 78, 97, 109, 101, 18, 33, 10, 12, 99, 111, 109, 109, 97, 110, 100, 95, 110, 97,
        109, 101, 24, 2, 32, 1, 40, 9, 82, 11, 99, 111, 109, 109, 97, 110, 100, 78, 97, 109, 101,
        18, 46, 10, 7, 112, 97, 121, 108, 111, 97, 100, 24, 3, 32, 1, 40, 11, 50, 20, 46, 103,
        111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121, 82,
        7, 112, 97, 121, 108, 111, 97, 100, 18, 32, 10, 11, 115, 121, 110, 99, 104, 114, 111, 110,
        111, 117, 115, 24, 4, 32, 1, 40, 8, 82, 11, 115, 121, 110, 99, 104, 114, 111, 110, 111,
        117, 115>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 7, 67, 111, 109, 109, 97, 110, 100, 18, 27, 10, 9, 101, 110, 116, 105, 116, 121, 95,
        105, 100, 24, 1, 32, 1, 40, 9, 82, 8, 101, 110, 116, 105, 116, 121, 73, 100, 18, 14, 10,
        2, 105, 100, 24, 2, 32, 1, 40, 3, 82, 2, 105, 100, 18, 18, 10, 4, 110, 97, 109, 101, 24,
        3, 32, 1, 40, 9, 82, 4, 110, 97, 109, 101, 18, 46, 10, 7, 112, 97, 121, 108, 111, 97, 100,
        24, 4, 32, 1, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116,
        111, 98, 117, 102, 46, 65, 110, 121, 82, 7, 112, 97, 121, 108, 111, 97, 100, 18, 26, 10,
        8, 115, 116, 114, 101, 97, 109, 101, 100, 24, 5, 32, 1, 40, 8, 82, 8, 115, 116, 114, 101,
        97, 109, 101, 100>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 15, 83, 116, 114, 101, 97, 109, 67, 97, 110, 99, 101, 108, 108, 101, 100, 18, 27, 10,
        9, 101, 110, 116, 105, 116, 121, 95, 105, 100, 24, 1, 32, 1, 40, 9, 82, 8, 101, 110, 116,
        105, 116, 121, 73, 100, 18, 14, 10, 2, 105, 100, 24, 2, 32, 1, 40, 3, 82, 2, 105, 100>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 7, 70, 97, 105, 108, 117, 114, 101, 18, 29, 10, 10, 99, 111, 109, 109, 97, 110, 100,
        95, 105, 100, 24, 1, 32, 1, 40, 3, 82, 9, 99, 111, 109, 109, 97, 110, 100, 73, 100, 18,
        32, 10, 11, 100, 101, 115, 99, 114, 105, 112, 116, 105, 111, 110, 24, 2, 32, 1, 40, 9, 82,
        11, 100, 101, 115, 99, 114, 105, 112, 116, 105, 111, 110>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 10, 69, 110, 116, 105, 116, 121, 83, 112, 101, 99, 18, 20, 10, 5, 112, 114, 111, 116,
        111, 24, 1, 32, 1, 40, 12, 82, 5, 112, 114, 111, 116, 111, 18, 46, 10, 8, 101, 110, 116,
        105, 116, 105, 101, 115, 24, 2, 32, 3, 40, 11, 50, 18, 46, 99, 108, 111, 117, 100, 115,
        116, 97, 116, 101, 46, 69, 110, 116, 105, 116, 121, 82, 8, 101, 110, 116, 105, 116, 105,
        101, 115, 18, 58, 10, 12, 115, 101, 114, 118, 105, 99, 101, 95, 105, 110, 102, 111, 24, 3,
        32, 1, 40, 11, 50, 23, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 83, 101,
        114, 118, 105, 99, 101, 73, 110, 102, 111, 82, 11, 115, 101, 114, 118, 105, 99, 101, 73,
        110, 102, 111>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 11, 83, 101, 114, 118, 105, 99, 101, 73, 110, 102, 111, 18, 33, 10, 12, 115, 101, 114,
        118, 105, 99, 101, 95, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9, 82, 11, 115, 101, 114, 118,
        105, 99, 101, 78, 97, 109, 101, 18, 39, 10, 15, 115, 101, 114, 118, 105, 99, 101, 95, 118,
        101, 114, 115, 105, 111, 110, 24, 2, 32, 1, 40, 9, 82, 14, 115, 101, 114, 118, 105, 99,
        101, 86, 101, 114, 115, 105, 111, 110, 18, 39, 10, 15, 115, 101, 114, 118, 105, 99, 101,
        95, 114, 117, 110, 116, 105, 109, 101, 24, 3, 32, 1, 40, 9, 82, 14, 115, 101, 114, 118,
        105, 99, 101, 82, 117, 110, 116, 105, 109, 101, 18, 48, 10, 20, 115, 117, 112, 112, 111,
        114, 116, 95, 108, 105, 98, 114, 97, 114, 121, 95, 110, 97, 109, 101, 24, 4, 32, 1, 40, 9,
        82, 18, 115, 117, 112, 112, 111, 114, 116, 76, 105, 98, 114, 97, 114, 121, 78, 97, 109,
        101, 18, 54, 10, 23, 115, 117, 112, 112, 111, 114, 116, 95, 108, 105, 98, 114, 97, 114,
        121, 95, 118, 101, 114, 115, 105, 111, 110, 24, 5, 32, 1, 40, 9, 82, 21, 115, 117, 112,
        112, 111, 114, 116, 76, 105, 98, 114, 97, 114, 121, 86, 101, 114, 115, 105, 111, 110>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 6, 69, 110, 116, 105, 116, 121, 18, 31, 10, 11, 101, 110, 116, 105, 116, 121, 95, 116,
        121, 112, 101, 24, 1, 32, 1, 40, 9, 82, 10, 101, 110, 116, 105, 116, 121, 84, 121, 112,
        101, 18, 33, 10, 12, 115, 101, 114, 118, 105, 99, 101, 95, 110, 97, 109, 101, 24, 2, 32,
        1, 40, 9, 82, 11, 115, 101, 114, 118, 105, 99, 101, 78, 97, 109, 101, 18, 37, 10, 14, 112,
        101, 114, 115, 105, 115, 116, 101, 110, 99, 101, 95, 105, 100, 24, 3, 32, 1, 40, 9, 82,
        13, 112, 101, 114, 115, 105, 115, 116, 101, 110, 99, 101, 73, 100>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 85, 115, 101, 114, 70, 117, 110, 99, 116, 105, 111, 110, 69, 114, 114, 111, 114,
        18, 24, 10, 7, 109, 101, 115, 115, 97, 103, 101, 24, 1, 32, 1, 40, 9, 82, 7, 109, 101,
        115, 115, 97, 103, 101>>
    )
  end

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

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 9, 80, 114, 111, 120, 121, 73, 110, 102, 111, 18, 52, 10, 22, 112, 114, 111, 116, 111,
        99, 111, 108, 95, 109, 97, 106, 111, 114, 95, 118, 101, 114, 115, 105, 111, 110, 24, 1,
        32, 1, 40, 5, 82, 20, 112, 114, 111, 116, 111, 99, 111, 108, 77, 97, 106, 111, 114, 86,
        101, 114, 115, 105, 111, 110, 18, 52, 10, 22, 112, 114, 111, 116, 111, 99, 111, 108, 95,
        109, 105, 110, 111, 114, 95, 118, 101, 114, 115, 105, 111, 110, 24, 2, 32, 1, 40, 5, 82,
        20, 112, 114, 111, 116, 111, 99, 111, 108, 77, 105, 110, 111, 114, 86, 101, 114, 115, 105,
        111, 110, 18, 29, 10, 10, 112, 114, 111, 120, 121, 95, 110, 97, 109, 101, 24, 3, 32, 1,
        40, 9, 82, 9, 112, 114, 111, 120, 121, 78, 97, 109, 101, 18, 35, 10, 13, 112, 114, 111,
        120, 121, 95, 118, 101, 114, 115, 105, 111, 110, 24, 4, 32, 1, 40, 9, 82, 12, 112, 114,
        111, 120, 121, 86, 101, 114, 115, 105, 111, 110, 18, 52, 10, 22, 115, 117, 112, 112, 111,
        114, 116, 101, 100, 95, 101, 110, 116, 105, 116, 121, 95, 116, 121, 112, 101, 115, 24, 5,
        32, 3, 40, 9, 82, 20, 115, 117, 112, 112, 111, 114, 116, 101, 100, 69, 110, 116, 105, 116,
        121, 84, 121, 112, 101, 115>>
    )
  end

  field(:protocol_major_version, 1, type: :int32)
  field(:protocol_minor_version, 2, type: :int32)
  field(:proxy_name, 3, type: :string)
  field(:proxy_version, 4, type: :string)
  field(:supported_entity_types, 5, repeated: true, type: :string)
end

defmodule Cloudstate.EntityDiscovery.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.EntityDiscovery"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 15, 69, 110, 116, 105, 116, 121, 68, 105, 115, 99, 111, 118, 101, 114, 121, 18, 66,
        10, 8, 100, 105, 115, 99, 111, 118, 101, 114, 18, 21, 46, 99, 108, 111, 117, 100, 115,
        116, 97, 116, 101, 46, 80, 114, 111, 120, 121, 73, 110, 102, 111, 26, 22, 46, 99, 108,
        111, 117, 100, 115, 116, 97, 116, 101, 46, 69, 110, 116, 105, 116, 121, 83, 112, 101, 99,
        34, 3, 136, 2, 0, 40, 0, 48, 0, 18, 77, 10, 11, 114, 101, 112, 111, 114, 116, 69, 114,
        114, 111, 114, 18, 29, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 85, 115,
        101, 114, 70, 117, 110, 99, 116, 105, 111, 110, 69, 114, 114, 111, 114, 26, 22, 46, 103,
        111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 69, 109, 112, 116,
        121, 34, 3, 136, 2, 0, 40, 0, 48, 0>>
    )
  end

  rpc(:discover, Cloudstate.ProxyInfo, Cloudstate.EntitySpec)

  rpc(:reportError, Cloudstate.UserFunctionError, Google.Protobuf.Empty)
end

defmodule Cloudstate.EntityDiscovery.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.EntityDiscovery.Service
end

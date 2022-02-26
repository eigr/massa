defmodule Grpc.Reflection.V1alpha.ServerReflectionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message_request: {atom, any},
          host: String.t()
        }
  defstruct [:message_request, :host]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 23, 83, 101, 114, 118, 101, 114, 82, 101, 102, 108, 101, 99, 116, 105, 111, 110, 82,
        101, 113, 117, 101, 115, 116, 18, 18, 10, 4, 104, 111, 115, 116, 24, 1, 32, 1, 40, 9, 82,
        4, 104, 111, 115, 116, 18, 42, 10, 16, 102, 105, 108, 101, 95, 98, 121, 95, 102, 105, 108,
        101, 110, 97, 109, 101, 24, 3, 32, 1, 40, 9, 72, 0, 82, 14, 102, 105, 108, 101, 66, 121,
        70, 105, 108, 101, 110, 97, 109, 101, 18, 54, 10, 22, 102, 105, 108, 101, 95, 99, 111,
        110, 116, 97, 105, 110, 105, 110, 103, 95, 115, 121, 109, 98, 111, 108, 24, 4, 32, 1, 40,
        9, 72, 0, 82, 20, 102, 105, 108, 101, 67, 111, 110, 116, 97, 105, 110, 105, 110, 103, 83,
        121, 109, 98, 111, 108, 18, 103, 10, 25, 102, 105, 108, 101, 95, 99, 111, 110, 116, 97,
        105, 110, 105, 110, 103, 95, 101, 120, 116, 101, 110, 115, 105, 111, 110, 24, 5, 32, 1,
        40, 11, 50, 41, 46, 103, 114, 112, 99, 46, 114, 101, 102, 108, 101, 99, 116, 105, 111,
        110, 46, 118, 49, 97, 108, 112, 104, 97, 46, 69, 120, 116, 101, 110, 115, 105, 111, 110,
        82, 101, 113, 117, 101, 115, 116, 72, 0, 82, 23, 102, 105, 108, 101, 67, 111, 110, 116,
        97, 105, 110, 105, 110, 103, 69, 120, 116, 101, 110, 115, 105, 111, 110, 18, 66, 10, 29,
        97, 108, 108, 95, 101, 120, 116, 101, 110, 115, 105, 111, 110, 95, 110, 117, 109, 98, 101,
        114, 115, 95, 111, 102, 95, 116, 121, 112, 101, 24, 6, 32, 1, 40, 9, 72, 0, 82, 25, 97,
        108, 108, 69, 120, 116, 101, 110, 115, 105, 111, 110, 78, 117, 109, 98, 101, 114, 115, 79,
        102, 84, 121, 112, 101, 18, 37, 10, 13, 108, 105, 115, 116, 95, 115, 101, 114, 118, 105,
        99, 101, 115, 24, 7, 32, 1, 40, 9, 72, 0, 82, 12, 108, 105, 115, 116, 83, 101, 114, 118,
        105, 99, 101, 115, 66, 17, 10, 15, 109, 101, 115, 115, 97, 103, 101, 95, 114, 101, 113,
        117, 101, 115, 116>>
    )
  end

  oneof :message_request, 0
  field :host, 1, type: :string
  field :file_by_filename, 3, type: :string, oneof: 0
  field :file_containing_symbol, 4, type: :string, oneof: 0
  field :file_containing_extension, 5, type: Grpc.Reflection.V1alpha.ExtensionRequest, oneof: 0
  field :all_extension_numbers_of_type, 6, type: :string, oneof: 0
  field :list_services, 7, type: :string, oneof: 0
end

defmodule Grpc.Reflection.V1alpha.ExtensionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          containing_type: String.t(),
          extension_number: integer
        }
  defstruct [:containing_type, :extension_number]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 16, 69, 120, 116, 101, 110, 115, 105, 111, 110, 82, 101, 113, 117, 101, 115, 116, 18,
        39, 10, 15, 99, 111, 110, 116, 97, 105, 110, 105, 110, 103, 95, 116, 121, 112, 101, 24, 1,
        32, 1, 40, 9, 82, 14, 99, 111, 110, 116, 97, 105, 110, 105, 110, 103, 84, 121, 112, 101,
        18, 41, 10, 16, 101, 120, 116, 101, 110, 115, 105, 111, 110, 95, 110, 117, 109, 98, 101,
        114, 24, 2, 32, 1, 40, 5, 82, 15, 101, 120, 116, 101, 110, 115, 105, 111, 110, 78, 117,
        109, 98, 101, 114>>
    )
  end

  field :containing_type, 1, type: :string
  field :extension_number, 2, type: :int32
end

defmodule Grpc.Reflection.V1alpha.ServerReflectionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message_response: {atom, any},
          valid_host: String.t(),
          original_request: Grpc.Reflection.V1alpha.ServerReflectionRequest.t() | nil
        }
  defstruct [:message_response, :valid_host, :original_request]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 24, 83, 101, 114, 118, 101, 114, 82, 101, 102, 108, 101, 99, 116, 105, 111, 110, 82,
        101, 115, 112, 111, 110, 115, 101, 18, 29, 10, 10, 118, 97, 108, 105, 100, 95, 104, 111,
        115, 116, 24, 1, 32, 1, 40, 9, 82, 9, 118, 97, 108, 105, 100, 72, 111, 115, 116, 18, 91,
        10, 16, 111, 114, 105, 103, 105, 110, 97, 108, 95, 114, 101, 113, 117, 101, 115, 116, 24,
        2, 32, 1, 40, 11, 50, 48, 46, 103, 114, 112, 99, 46, 114, 101, 102, 108, 101, 99, 116,
        105, 111, 110, 46, 118, 49, 97, 108, 112, 104, 97, 46, 83, 101, 114, 118, 101, 114, 82,
        101, 102, 108, 101, 99, 116, 105, 111, 110, 82, 101, 113, 117, 101, 115, 116, 82, 15, 111,
        114, 105, 103, 105, 110, 97, 108, 82, 101, 113, 117, 101, 115, 116, 18, 107, 10, 24, 102,
        105, 108, 101, 95, 100, 101, 115, 99, 114, 105, 112, 116, 111, 114, 95, 114, 101, 115,
        112, 111, 110, 115, 101, 24, 4, 32, 1, 40, 11, 50, 47, 46, 103, 114, 112, 99, 46, 114,
        101, 102, 108, 101, 99, 116, 105, 111, 110, 46, 118, 49, 97, 108, 112, 104, 97, 46, 70,
        105, 108, 101, 68, 101, 115, 99, 114, 105, 112, 116, 111, 114, 82, 101, 115, 112, 111,
        110, 115, 101, 72, 0, 82, 22, 102, 105, 108, 101, 68, 101, 115, 99, 114, 105, 112, 116,
        111, 114, 82, 101, 115, 112, 111, 110, 115, 101, 18, 119, 10, 30, 97, 108, 108, 95, 101,
        120, 116, 101, 110, 115, 105, 111, 110, 95, 110, 117, 109, 98, 101, 114, 115, 95, 114,
        101, 115, 112, 111, 110, 115, 101, 24, 5, 32, 1, 40, 11, 50, 48, 46, 103, 114, 112, 99,
        46, 114, 101, 102, 108, 101, 99, 116, 105, 111, 110, 46, 118, 49, 97, 108, 112, 104, 97,
        46, 69, 120, 116, 101, 110, 115, 105, 111, 110, 78, 117, 109, 98, 101, 114, 82, 101, 115,
        112, 111, 110, 115, 101, 72, 0, 82, 27, 97, 108, 108, 69, 120, 116, 101, 110, 115, 105,
        111, 110, 78, 117, 109, 98, 101, 114, 115, 82, 101, 115, 112, 111, 110, 115, 101, 18, 100,
        10, 22, 108, 105, 115, 116, 95, 115, 101, 114, 118, 105, 99, 101, 115, 95, 114, 101, 115,
        112, 111, 110, 115, 101, 24, 6, 32, 1, 40, 11, 50, 44, 46, 103, 114, 112, 99, 46, 114,
        101, 102, 108, 101, 99, 116, 105, 111, 110, 46, 118, 49, 97, 108, 112, 104, 97, 46, 76,
        105, 115, 116, 83, 101, 114, 118, 105, 99, 101, 82, 101, 115, 112, 111, 110, 115, 101, 72,
        0, 82, 20, 108, 105, 115, 116, 83, 101, 114, 118, 105, 99, 101, 115, 82, 101, 115, 112,
        111, 110, 115, 101, 18, 79, 10, 14, 101, 114, 114, 111, 114, 95, 114, 101, 115, 112, 111,
        110, 115, 101, 24, 7, 32, 1, 40, 11, 50, 38, 46, 103, 114, 112, 99, 46, 114, 101, 102,
        108, 101, 99, 116, 105, 111, 110, 46, 118, 49, 97, 108, 112, 104, 97, 46, 69, 114, 114,
        111, 114, 82, 101, 115, 112, 111, 110, 115, 101, 72, 0, 82, 13, 101, 114, 114, 111, 114,
        82, 101, 115, 112, 111, 110, 115, 101, 66, 18, 10, 16, 109, 101, 115, 115, 97, 103, 101,
        95, 114, 101, 115, 112, 111, 110, 115, 101>>
    )
  end

  oneof :message_response, 0
  field :valid_host, 1, type: :string
  field :original_request, 2, type: Grpc.Reflection.V1alpha.ServerReflectionRequest

  field :file_descriptor_response, 4,
    type: Grpc.Reflection.V1alpha.FileDescriptorResponse,
    oneof: 0

  field :all_extension_numbers_response, 5,
    type: Grpc.Reflection.V1alpha.ExtensionNumberResponse,
    oneof: 0

  field :list_services_response, 6, type: Grpc.Reflection.V1alpha.ListServiceResponse, oneof: 0
  field :error_response, 7, type: Grpc.Reflection.V1alpha.ErrorResponse, oneof: 0
end

defmodule Grpc.Reflection.V1alpha.FileDescriptorResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          file_descriptor_proto: [binary]
        }
  defstruct [:file_descriptor_proto]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 22, 70, 105, 108, 101, 68, 101, 115, 99, 114, 105, 112, 116, 111, 114, 82, 101, 115,
        112, 111, 110, 115, 101, 18, 50, 10, 21, 102, 105, 108, 101, 95, 100, 101, 115, 99, 114,
        105, 112, 116, 111, 114, 95, 112, 114, 111, 116, 111, 24, 1, 32, 3, 40, 12, 82, 19, 102,
        105, 108, 101, 68, 101, 115, 99, 114, 105, 112, 116, 111, 114, 80, 114, 111, 116, 111>>
    )
  end

  field :file_descriptor_proto, 1, repeated: true, type: :bytes
end

defmodule Grpc.Reflection.V1alpha.ExtensionNumberResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          base_type_name: String.t(),
          extension_number: [integer]
        }
  defstruct [:base_type_name, :extension_number]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 23, 69, 120, 116, 101, 110, 115, 105, 111, 110, 78, 117, 109, 98, 101, 114, 82, 101,
        115, 112, 111, 110, 115, 101, 18, 36, 10, 14, 98, 97, 115, 101, 95, 116, 121, 112, 101,
        95, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9, 82, 12, 98, 97, 115, 101, 84, 121, 112, 101,
        78, 97, 109, 101, 18, 41, 10, 16, 101, 120, 116, 101, 110, 115, 105, 111, 110, 95, 110,
        117, 109, 98, 101, 114, 24, 2, 32, 3, 40, 5, 82, 15, 101, 120, 116, 101, 110, 115, 105,
        111, 110, 78, 117, 109, 98, 101, 114>>
    )
  end

  field :base_type_name, 1, type: :string
  field :extension_number, 2, repeated: true, type: :int32
end

defmodule Grpc.Reflection.V1alpha.ListServiceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service: [Grpc.Reflection.V1alpha.ServiceResponse.t()]
        }
  defstruct [:service]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 19, 76, 105, 115, 116, 83, 101, 114, 118, 105, 99, 101, 82, 101, 115, 112, 111, 110,
        115, 101, 18, 66, 10, 7, 115, 101, 114, 118, 105, 99, 101, 24, 1, 32, 3, 40, 11, 50, 40,
        46, 103, 114, 112, 99, 46, 114, 101, 102, 108, 101, 99, 116, 105, 111, 110, 46, 118, 49,
        97, 108, 112, 104, 97, 46, 83, 101, 114, 118, 105, 99, 101, 82, 101, 115, 112, 111, 110,
        115, 101, 82, 7, 115, 101, 114, 118, 105, 99, 101>>
    )
  end

  field :service, 1, repeated: true, type: Grpc.Reflection.V1alpha.ServiceResponse
end

defmodule Grpc.Reflection.V1alpha.ServiceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 15, 83, 101, 114, 118, 105, 99, 101, 82, 101, 115, 112, 111, 110, 115, 101, 18, 18,
        10, 4, 110, 97, 109, 101, 24, 1, 32, 1, 40, 9, 82, 4, 110, 97, 109, 101>>
    )
  end

  field :name, 1, type: :string
end

defmodule Grpc.Reflection.V1alpha.ErrorResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          error_code: integer,
          error_message: String.t()
        }
  defstruct [:error_code, :error_message]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 13, 69, 114, 114, 111, 114, 82, 101, 115, 112, 111, 110, 115, 101, 18, 29, 10, 10,
        101, 114, 114, 111, 114, 95, 99, 111, 100, 101, 24, 1, 32, 1, 40, 5, 82, 9, 101, 114, 114,
        111, 114, 67, 111, 100, 101, 18, 35, 10, 13, 101, 114, 114, 111, 114, 95, 109, 101, 115,
        115, 97, 103, 101, 24, 2, 32, 1, 40, 9, 82, 12, 101, 114, 114, 111, 114, 77, 101, 115,
        115, 97, 103, 101>>
    )
  end

  field :error_code, 1, type: :int32
  field :error_message, 2, type: :string
end

defmodule Grpc.Reflection.V1alpha.ServerReflection.Service do
  @moduledoc false
  use GRPC.Service, name: "grpc.reflection.v1alpha.ServerReflection"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 16, 83, 101, 114, 118, 101, 114, 82, 101, 102, 108, 101, 99, 116, 105, 111, 110, 18,
        127, 10, 20, 83, 101, 114, 118, 101, 114, 82, 101, 102, 108, 101, 99, 116, 105, 111, 110,
        73, 110, 102, 111, 18, 48, 46, 103, 114, 112, 99, 46, 114, 101, 102, 108, 101, 99, 116,
        105, 111, 110, 46, 118, 49, 97, 108, 112, 104, 97, 46, 83, 101, 114, 118, 101, 114, 82,
        101, 102, 108, 101, 99, 116, 105, 111, 110, 82, 101, 113, 117, 101, 115, 116, 26, 49, 46,
        103, 114, 112, 99, 46, 114, 101, 102, 108, 101, 99, 116, 105, 111, 110, 46, 118, 49, 97,
        108, 112, 104, 97, 46, 83, 101, 114, 118, 101, 114, 82, 101, 102, 108, 101, 99, 116, 105,
        111, 110, 82, 101, 115, 112, 111, 110, 115, 101, 40, 1, 48, 1>>
    )
  end

  rpc :ServerReflectionInfo,
      stream(Grpc.Reflection.V1alpha.ServerReflectionRequest),
      stream(Grpc.Reflection.V1alpha.ServerReflectionResponse)
end

defmodule Grpc.Reflection.V1alpha.ServerReflection.Stub do
  @moduledoc false
  use GRPC.Stub, service: Grpc.Reflection.V1alpha.ServerReflection.Service
end

defmodule Google.Api.Http do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rules: [Google.Api.HttpRule.t()],
          fully_decode_reserved_expansion: boolean
        }

  defstruct [:rules, :fully_decode_reserved_expansion]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 4, 72, 116, 116, 112, 18, 42, 10, 5, 114, 117, 108, 101, 115, 24, 1, 32, 3, 40, 11,
        50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 97, 112, 105, 46, 72, 116, 116, 112, 82,
        117, 108, 101, 82, 5, 114, 117, 108, 101, 115, 18, 69, 10, 31, 102, 117, 108, 108, 121,
        95, 100, 101, 99, 111, 100, 101, 95, 114, 101, 115, 101, 114, 118, 101, 100, 95, 101, 120,
        112, 97, 110, 115, 105, 111, 110, 24, 2, 32, 1, 40, 8, 82, 28, 102, 117, 108, 108, 121,
        68, 101, 99, 111, 100, 101, 82, 101, 115, 101, 114, 118, 101, 100, 69, 120, 112, 97, 110,
        115, 105, 111, 110>>
    )
  end

  field(:rules, 1, repeated: true, type: Google.Api.HttpRule)
  field(:fully_decode_reserved_expansion, 2, type: :bool)
end

defmodule Google.Api.HttpRule do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pattern: {atom, any},
          selector: String.t(),
          body: String.t(),
          response_body: String.t(),
          additional_bindings: [Google.Api.HttpRule.t()]
        }

  defstruct [:pattern, :selector, :body, :response_body, :additional_bindings]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 8, 72, 116, 116, 112, 82, 117, 108, 101, 18, 26, 10, 8, 115, 101, 108, 101, 99, 116,
        111, 114, 24, 1, 32, 1, 40, 9, 82, 8, 115, 101, 108, 101, 99, 116, 111, 114, 18, 18, 10,
        3, 103, 101, 116, 24, 2, 32, 1, 40, 9, 72, 0, 82, 3, 103, 101, 116, 18, 18, 10, 3, 112,
        117, 116, 24, 3, 32, 1, 40, 9, 72, 0, 82, 3, 112, 117, 116, 18, 20, 10, 4, 112, 111, 115,
        116, 24, 4, 32, 1, 40, 9, 72, 0, 82, 4, 112, 111, 115, 116, 18, 24, 10, 6, 100, 101, 108,
        101, 116, 101, 24, 5, 32, 1, 40, 9, 72, 0, 82, 6, 100, 101, 108, 101, 116, 101, 18, 22,
        10, 5, 112, 97, 116, 99, 104, 24, 6, 32, 1, 40, 9, 72, 0, 82, 5, 112, 97, 116, 99, 104,
        18, 55, 10, 6, 99, 117, 115, 116, 111, 109, 24, 8, 32, 1, 40, 11, 50, 29, 46, 103, 111,
        111, 103, 108, 101, 46, 97, 112, 105, 46, 67, 117, 115, 116, 111, 109, 72, 116, 116, 112,
        80, 97, 116, 116, 101, 114, 110, 72, 0, 82, 6, 99, 117, 115, 116, 111, 109, 18, 18, 10, 4,
        98, 111, 100, 121, 24, 7, 32, 1, 40, 9, 82, 4, 98, 111, 100, 121, 18, 35, 10, 13, 114,
        101, 115, 112, 111, 110, 115, 101, 95, 98, 111, 100, 121, 24, 12, 32, 1, 40, 9, 82, 12,
        114, 101, 115, 112, 111, 110, 115, 101, 66, 111, 100, 121, 18, 69, 10, 19, 97, 100, 100,
        105, 116, 105, 111, 110, 97, 108, 95, 98, 105, 110, 100, 105, 110, 103, 115, 24, 11, 32,
        3, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 97, 112, 105, 46, 72, 116, 116,
        112, 82, 117, 108, 101, 82, 18, 97, 100, 100, 105, 116, 105, 111, 110, 97, 108, 66, 105,
        110, 100, 105, 110, 103, 115, 66, 9, 10, 7, 112, 97, 116, 116, 101, 114, 110>>
    )
  end

  oneof(:pattern, 0)
  field(:selector, 1, type: :string)
  field(:get, 2, type: :string, oneof: 0)
  field(:put, 3, type: :string, oneof: 0)
  field(:post, 4, type: :string, oneof: 0)
  field(:delete, 5, type: :string, oneof: 0)
  field(:patch, 6, type: :string, oneof: 0)
  field(:custom, 8, type: Google.Api.CustomHttpPattern, oneof: 0)
  field(:body, 7, type: :string)
  field(:response_body, 12, type: :string)
  field(:additional_bindings, 11, repeated: true, type: Google.Api.HttpRule)
end

defmodule Google.Api.CustomHttpPattern do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          kind: String.t(),
          path: String.t()
        }

  defstruct [:kind, :path]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 67, 117, 115, 116, 111, 109, 72, 116, 116, 112, 80, 97, 116, 116, 101, 114, 110,
        18, 18, 10, 4, 107, 105, 110, 100, 24, 1, 32, 1, 40, 9, 82, 4, 107, 105, 110, 100, 18, 18,
        10, 4, 112, 97, 116, 104, 24, 2, 32, 1, 40, 9, 82, 4, 112, 97, 116, 104>>
    )
  end

  field(:kind, 1, type: :string)
  field(:path, 2, type: :string)
end

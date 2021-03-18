defmodule Google.Api.HttpBody do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          content_type: String.t(),
          data: binary,
          extensions: [Google.Protobuf.Any.t()]
        }

  defstruct [:content_type, :data, :extensions]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 8, 72, 116, 116, 112, 66, 111, 100, 121, 18, 33, 10, 12, 99, 111, 110, 116, 101, 110,
        116, 95, 116, 121, 112, 101, 24, 1, 32, 1, 40, 9, 82, 11, 99, 111, 110, 116, 101, 110,
        116, 84, 121, 112, 101, 18, 18, 10, 4, 100, 97, 116, 97, 24, 2, 32, 1, 40, 12, 82, 4, 100,
        97, 116, 97, 18, 52, 10, 10, 101, 120, 116, 101, 110, 115, 105, 111, 110, 115, 24, 3, 32,
        3, 40, 11, 50, 20, 46, 103, 111, 111, 103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117,
        102, 46, 65, 110, 121, 82, 10, 101, 120, 116, 101, 110, 115, 105, 111, 110, 115>>
    )
  end

  field :content_type, 1, type: :string
  field :data, 2, type: :bytes
  field :extensions, 3, repeated: true, type: Google.Protobuf.Any
end

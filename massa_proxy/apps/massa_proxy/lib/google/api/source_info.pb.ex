defmodule Google.Api.SourceInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          source_files: [Google.Protobuf.Any.t()]
        }

  defstruct [:source_files]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 10, 83, 111, 117, 114, 99, 101, 73, 110, 102, 111, 18, 55, 10, 12, 115, 111, 117, 114,
        99, 101, 95, 102, 105, 108, 101, 115, 24, 1, 32, 3, 40, 11, 50, 20, 46, 103, 111, 111,
        103, 108, 101, 46, 112, 114, 111, 116, 111, 98, 117, 102, 46, 65, 110, 121, 82, 11, 115,
        111, 117, 114, 99, 101, 70, 105, 108, 101, 115>>
    )
  end

  field :source_files, 1, repeated: true, type: Google.Protobuf.Any
end

defmodule Cloudstate.Eventing do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          in: Cloudstate.EventSource.t() | nil,
          out: Cloudstate.EventDestination.t() | nil
        }

  defstruct [:in, :out]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 8, 69, 118, 101, 110, 116, 105, 110, 103, 18, 39, 10, 2, 105, 110, 24, 1, 32, 1, 40,
        11, 50, 23, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 69, 118, 101, 110,
        116, 83, 111, 117, 114, 99, 101, 82, 2, 105, 110, 18, 46, 10, 3, 111, 117, 116, 24, 2, 32,
        1, 40, 11, 50, 28, 46, 99, 108, 111, 117, 100, 115, 116, 97, 116, 101, 46, 69, 118, 101,
        110, 116, 68, 101, 115, 116, 105, 110, 97, 116, 105, 111, 110, 82, 3, 111, 117, 116>>
    )
  end

  field(:in, 1, type: Cloudstate.EventSource)
  field(:out, 2, type: Cloudstate.EventDestination)
end

defmodule Cloudstate.EventSource do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          source: {atom, any},
          consumer_group: String.t()
        }

  defstruct [:source, :consumer_group]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 11, 69, 118, 101, 110, 116, 83, 111, 117, 114, 99, 101, 18, 37, 10, 14, 99, 111, 110,
        115, 117, 109, 101, 114, 95, 103, 114, 111, 117, 112, 24, 1, 32, 1, 40, 9, 82, 13, 99,
        111, 110, 115, 117, 109, 101, 114, 71, 114, 111, 117, 112, 18, 22, 10, 5, 116, 111, 112,
        105, 99, 24, 2, 32, 1, 40, 9, 72, 0, 82, 5, 116, 111, 112, 105, 99, 18, 29, 10, 9, 101,
        118, 101, 110, 116, 95, 108, 111, 103, 24, 3, 32, 1, 40, 9, 72, 0, 82, 8, 101, 118, 101,
        110, 116, 76, 111, 103, 66, 8, 10, 6, 115, 111, 117, 114, 99, 101>>
    )
  end

  oneof(:source, 0)

  field(:consumer_group, 1, type: :string)
  field(:topic, 2, type: :string, oneof: 0)
  field(:event_log, 3, type: :string, oneof: 0)
end

defmodule Cloudstate.EventDestination do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          destination: {atom, any}
        }

  defstruct [:destination]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 16, 69, 118, 101, 110, 116, 68, 101, 115, 116, 105, 110, 97, 116, 105, 111, 110, 18,
        22, 10, 5, 116, 111, 112, 105, 99, 24, 1, 32, 1, 40, 9, 72, 0, 82, 5, 116, 111, 112, 105,
        99, 66, 13, 10, 11, 100, 101, 115, 116, 105, 110, 97, 116, 105, 111, 110>>
    )
  end

  oneof(:destination, 0)

  field(:topic, 1, type: :string, oneof: 0)
end

defmodule Cloudstate.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto3

  extend(Google.Protobuf.MethodOptions, :eventing, 1081, optional: true, type: Cloudstate.Eventing)
end

defmodule Cloudstate.Function.FunctionCommand do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          service_name: String.t(),
          name: String.t(),
          payload: Google.Protobuf.Any.t() | nil
        }

  defstruct [:service_name, :name, :payload]

  field :service_name, 2, type: :string
  field :name, 3, type: :string
  field :payload, 4, type: Google.Protobuf.Any
end

defmodule Cloudstate.Function.FunctionReply do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          response: {atom, any},
          side_effects: [Cloudstate.SideEffect.t()]
        }

  defstruct [:response, :side_effects]

  oneof :response, 0
  field :failure, 1, type: Cloudstate.Failure, oneof: 0
  field :reply, 2, type: Cloudstate.Reply, oneof: 0
  field :forward, 3, type: Cloudstate.Forward, oneof: 0
  field :side_effects, 4, repeated: true, type: Cloudstate.SideEffect
end

defmodule Cloudstate.Function.StatelessFunction.Service do
  @moduledoc false
  use GRPC.Service, name: "cloudstate.function.StatelessFunction"

  rpc :handleUnary, Cloudstate.Function.FunctionCommand, Cloudstate.Function.FunctionReply

  rpc :handleStreamedIn,
      stream(Cloudstate.Function.FunctionCommand),
      Cloudstate.Function.FunctionReply

  rpc :handleStreamedOut,
      Cloudstate.Function.FunctionCommand,
      stream(Cloudstate.Function.FunctionReply)

  rpc :handleStreamed,
      stream(Cloudstate.Function.FunctionCommand),
      stream(Cloudstate.Function.FunctionReply)
end

defmodule Cloudstate.Function.StatelessFunction.Stub do
  @moduledoc false
  use GRPC.Stub, service: Cloudstate.Function.StatelessFunction.Service
end

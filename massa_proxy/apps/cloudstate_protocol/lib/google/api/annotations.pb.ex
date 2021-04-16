defmodule Google.Api.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto3

  extend(Google.Protobuf.MethodOptions, :http, 72_295_728,
    optional: true,
    type: Google.Api.HttpRule
  )
end

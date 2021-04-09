defmodule Cloudstate.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto3
  extend(Google.Protobuf.FieldOptions, :entity_key, 1080, optional: true, type: :bool)
end

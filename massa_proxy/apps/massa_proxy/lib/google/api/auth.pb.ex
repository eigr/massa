defmodule Google.Api.Authentication do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rules: [Google.Api.AuthenticationRule.t()],
          providers: [Google.Api.AuthProvider.t()]
        }

  defstruct [:rules, :providers]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 14, 65, 117, 116, 104, 101, 110, 116, 105, 99, 97, 116, 105, 111, 110, 18, 52, 10, 5,
        114, 117, 108, 101, 115, 24, 3, 32, 3, 40, 11, 50, 30, 46, 103, 111, 111, 103, 108, 101,
        46, 97, 112, 105, 46, 65, 117, 116, 104, 101, 110, 116, 105, 99, 97, 116, 105, 111, 110,
        82, 117, 108, 101, 82, 5, 114, 117, 108, 101, 115, 18, 54, 10, 9, 112, 114, 111, 118, 105,
        100, 101, 114, 115, 24, 4, 32, 3, 40, 11, 50, 24, 46, 103, 111, 111, 103, 108, 101, 46,
        97, 112, 105, 46, 65, 117, 116, 104, 80, 114, 111, 118, 105, 100, 101, 114, 82, 9, 112,
        114, 111, 118, 105, 100, 101, 114, 115>>
    )
  end

  field :rules, 3, repeated: true, type: Google.Api.AuthenticationRule
  field :providers, 4, repeated: true, type: Google.Api.AuthProvider
end

defmodule Google.Api.AuthenticationRule do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          selector: String.t(),
          oauth: Google.Api.OAuthRequirements.t() | nil,
          allow_without_credential: boolean,
          requirements: [Google.Api.AuthRequirement.t()]
        }

  defstruct [:selector, :oauth, :allow_without_credential, :requirements]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 18, 65, 117, 116, 104, 101, 110, 116, 105, 99, 97, 116, 105, 111, 110, 82, 117, 108,
        101, 18, 26, 10, 8, 115, 101, 108, 101, 99, 116, 111, 114, 24, 1, 32, 1, 40, 9, 82, 8,
        115, 101, 108, 101, 99, 116, 111, 114, 18, 51, 10, 5, 111, 97, 117, 116, 104, 24, 2, 32,
        1, 40, 11, 50, 29, 46, 103, 111, 111, 103, 108, 101, 46, 97, 112, 105, 46, 79, 65, 117,
        116, 104, 82, 101, 113, 117, 105, 114, 101, 109, 101, 110, 116, 115, 82, 5, 111, 97, 117,
        116, 104, 18, 56, 10, 24, 97, 108, 108, 111, 119, 95, 119, 105, 116, 104, 111, 117, 116,
        95, 99, 114, 101, 100, 101, 110, 116, 105, 97, 108, 24, 5, 32, 1, 40, 8, 82, 22, 97, 108,
        108, 111, 119, 87, 105, 116, 104, 111, 117, 116, 67, 114, 101, 100, 101, 110, 116, 105,
        97, 108, 18, 63, 10, 12, 114, 101, 113, 117, 105, 114, 101, 109, 101, 110, 116, 115, 24,
        7, 32, 3, 40, 11, 50, 27, 46, 103, 111, 111, 103, 108, 101, 46, 97, 112, 105, 46, 65, 117,
        116, 104, 82, 101, 113, 117, 105, 114, 101, 109, 101, 110, 116, 82, 12, 114, 101, 113,
        117, 105, 114, 101, 109, 101, 110, 116, 115>>
    )
  end

  field :selector, 1, type: :string
  field :oauth, 2, type: Google.Api.OAuthRequirements
  field :allow_without_credential, 5, type: :bool
  field :requirements, 7, repeated: true, type: Google.Api.AuthRequirement
end

defmodule Google.Api.JwtLocation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          in: {atom, any},
          value_prefix: String.t()
        }

  defstruct [:in, :value_prefix]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 11, 74, 119, 116, 76, 111, 99, 97, 116, 105, 111, 110, 18, 24, 10, 6, 104, 101, 97,
        100, 101, 114, 24, 1, 32, 1, 40, 9, 72, 0, 82, 6, 104, 101, 97, 100, 101, 114, 18, 22, 10,
        5, 113, 117, 101, 114, 121, 24, 2, 32, 1, 40, 9, 72, 0, 82, 5, 113, 117, 101, 114, 121,
        18, 33, 10, 12, 118, 97, 108, 117, 101, 95, 112, 114, 101, 102, 105, 120, 24, 3, 32, 1,
        40, 9, 82, 11, 118, 97, 108, 117, 101, 80, 114, 101, 102, 105, 120, 66, 4, 10, 2, 105,
        110>>
    )
  end

  oneof :in, 0
  field :header, 1, type: :string, oneof: 0
  field :query, 2, type: :string, oneof: 0
  field :value_prefix, 3, type: :string
end

defmodule Google.Api.AuthProvider do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          issuer: String.t(),
          jwks_uri: String.t(),
          audiences: String.t(),
          authorization_url: String.t(),
          jwt_locations: [Google.Api.JwtLocation.t()]
        }

  defstruct [:id, :issuer, :jwks_uri, :audiences, :authorization_url, :jwt_locations]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 12, 65, 117, 116, 104, 80, 114, 111, 118, 105, 100, 101, 114, 18, 14, 10, 2, 105, 100,
        24, 1, 32, 1, 40, 9, 82, 2, 105, 100, 18, 22, 10, 6, 105, 115, 115, 117, 101, 114, 24, 2,
        32, 1, 40, 9, 82, 6, 105, 115, 115, 117, 101, 114, 18, 25, 10, 8, 106, 119, 107, 115, 95,
        117, 114, 105, 24, 3, 32, 1, 40, 9, 82, 7, 106, 119, 107, 115, 85, 114, 105, 18, 28, 10,
        9, 97, 117, 100, 105, 101, 110, 99, 101, 115, 24, 4, 32, 1, 40, 9, 82, 9, 97, 117, 100,
        105, 101, 110, 99, 101, 115, 18, 43, 10, 17, 97, 117, 116, 104, 111, 114, 105, 122, 97,
        116, 105, 111, 110, 95, 117, 114, 108, 24, 5, 32, 1, 40, 9, 82, 16, 97, 117, 116, 104,
        111, 114, 105, 122, 97, 116, 105, 111, 110, 85, 114, 108, 18, 60, 10, 13, 106, 119, 116,
        95, 108, 111, 99, 97, 116, 105, 111, 110, 115, 24, 6, 32, 3, 40, 11, 50, 23, 46, 103, 111,
        111, 103, 108, 101, 46, 97, 112, 105, 46, 74, 119, 116, 76, 111, 99, 97, 116, 105, 111,
        110, 82, 12, 106, 119, 116, 76, 111, 99, 97, 116, 105, 111, 110, 115>>
    )
  end

  field :id, 1, type: :string
  field :issuer, 2, type: :string
  field :jwks_uri, 3, type: :string
  field :audiences, 4, type: :string
  field :authorization_url, 5, type: :string
  field :jwt_locations, 6, repeated: true, type: Google.Api.JwtLocation
end

defmodule Google.Api.OAuthRequirements do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          canonical_scopes: String.t()
        }

  defstruct [:canonical_scopes]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 17, 79, 65, 117, 116, 104, 82, 101, 113, 117, 105, 114, 101, 109, 101, 110, 116, 115,
        18, 41, 10, 16, 99, 97, 110, 111, 110, 105, 99, 97, 108, 95, 115, 99, 111, 112, 101, 115,
        24, 1, 32, 1, 40, 9, 82, 15, 99, 97, 110, 111, 110, 105, 99, 97, 108, 83, 99, 111, 112,
        101, 115>>
    )
  end

  field :canonical_scopes, 1, type: :string
end

defmodule Google.Api.AuthRequirement do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          provider_id: String.t(),
          audiences: String.t()
        }

  defstruct [:provider_id, :audiences]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 15, 65, 117, 116, 104, 82, 101, 113, 117, 105, 114, 101, 109, 101, 110, 116, 18, 31,
        10, 11, 112, 114, 111, 118, 105, 100, 101, 114, 95, 105, 100, 24, 1, 32, 1, 40, 9, 82, 10,
        112, 114, 111, 118, 105, 100, 101, 114, 73, 100, 18, 28, 10, 9, 97, 117, 100, 105, 101,
        110, 99, 101, 115, 24, 2, 32, 1, 40, 9, 82, 9, 97, 117, 100, 105, 101, 110, 99, 101, 115>>
    )
  end

  field :provider_id, 1, type: :string
  field :audiences, 2, type: :string
end

defmodule MassaProxy.Infra.Cache.Distributed do
  use Nebulex.Cache,
    otp_app: :massa_proxy,
    adapter: Nebulex.Adapters.Partitioned
end

defmodule Metrics.Setup do
  @moduledoc false

  def setup do
    Metrics.ProxyInstrumenter.setup()
    GRPCPrometheus.ServerInterceptor.setup()
    Http.MetricsExporter.setup()
  end
end

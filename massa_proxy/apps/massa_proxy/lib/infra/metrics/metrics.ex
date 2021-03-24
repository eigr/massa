defmodule Metrics.Setup do
  @moduledoc false

  def setup do
    Metrics.ProxyInstrumenter.setup()
    Http.MetricsExporter.setup()
    GRPCPrometheus.ServerInterceptor.setup()
  end
end

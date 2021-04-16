defmodule Metrics.Setup do
  @moduledoc false

  def setup do
    Http.PlugExporter.setup()
    Http.MetricsExporter.setup()
    Metrics.ProxyInstrumenter.setup()
    GRPCPrometheus.ServerInterceptor.setup()
  end
end

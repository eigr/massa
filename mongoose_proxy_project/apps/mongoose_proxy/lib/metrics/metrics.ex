defmodule Metrics.Setup do
  def setup do
    Metrics.ProxyInstrumenter.setup()
    Http.MetricsExporter.setup()
  end
end

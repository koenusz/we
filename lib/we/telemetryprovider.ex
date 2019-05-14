defmodule WE.TelemetryProvider do
  @callback onTaskStart(DateTime.t(), term) :: :ok | :error
  @callback onTaskComplete(DateTime.t(), term) :: :ok | :error
  @callback onEvent(DateTime.t(), term) :: :ok | :error
end

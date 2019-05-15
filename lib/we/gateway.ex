defmodule WE.Gateway do
  alias WE.{Gateway, SequenceFlow}

  @type gateway :: :none | :exclusive | :default | :event | :parallel | :inclusive

  def none(sequence_flows, _fun, _data) do
    sequence_flows
    |> IO.inspect()
    |> Enum.filter(fn sf -> default(sf) end)
  end

  def complex(sequenceFlows, fun, data) when is_function(fun) do
    sequenceFlows
    |> Enum.filter(fn sf -> fun.(sf, data) end)
  end

  def exclusive do
  end

  @spec default(SequenceFlow.t()) :: boolean
  def default(sequence_flow) do
    sequence_flow.default == true
  end
end

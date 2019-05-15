defmodule WE.Gateway do
  alias WE.{Gateway, SequenceFlow}

  @type gateway :: :none | :exclusive | :default | :event | :parallel | :inclusive

  @spec none([%SequenceFlow{}], fun(), any()) :: [%SequenceFlow{}]
  def none(sequence_flows, _fun, _data) do
    IO.puts("here")

    sequence_flows
    |> IO.inspect()
    |> Enum.filter(fn sf -> Map.get(sf, :from) == "" end)
    |> IO.inspect()
  end

  @spec complex([%SequenceFlow{}], fun(), any()) :: [%SequenceFlow{}]
  def complex(sequenceFlows, fun, data) when is_function(fun) do
    sequenceFlows
    |> Enum.filter(fn sf -> fun.(sf, data) end)
  end

  def exclusive do
  end
end

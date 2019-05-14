defmodule WE.Event do
  use TypedStruct
  alias WE.{Event, SequenceFlow, Gateway}

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t())
    field :type, atom(), default: :message
    field :gateway, atom(), default: :none
  end

  @spec next(%Event{}, term()) :: :error | {:ok, [%SequenceFlow{}]}
  def next(event, data) do
    args =
      [event.sequence_flows, [], data]
      |> IO.inspect()

    apply(Gateway, event.gateway, args)
    |> IO.inspect()
  end

  def start_event(name, sequence_flows) do
    %Event{name: name, type: :start, sequence_flows: sequence_flows}
  end

  def end_event(name) do
    %Event{name: name, type: :end, sequence_flows: []}
  end

  def message_event(name, sequence_flows) do
    %Event{name: name, type: :message, sequence_flows: sequence_flows}
  end
end

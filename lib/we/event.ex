defmodule WE.Event do
  use TypedStruct
  alias WE.{Event, SequenceFlow, Gateway}

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t())
    field :type, atom(), default: :message
    field :gateway, Gateway.gateway(), default: :none
  end

  @spec next(Event.t(), term()) :: :error | {:ok, [SequenceFlow.t()]}
  def next(event, data) do
    args = [event.sequence_flows, [], data]
    apply(Gateway, event.gateway, args)
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

  @spec add_sequence_flow(%Event{}, SequenceFlow.t()) :: %Event{}
  def add_sequence_flow(event, sequence_flow) do
    %{event | sequence_flows: [sequence_flow | event.sequence_flows]}
  end
end

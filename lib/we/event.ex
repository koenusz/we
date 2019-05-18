defmodule WE.Event do
  use TypedStruct
  alias WE.{Event, SequenceFlow}

  @type event_type :: :start | :end | :message

  typedstruct enforce: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t())
    field :type, event_type(), default: :message
  end

  @spec next(Event.t()) :: :error | [SequenceFlow.t()]
  def next(event) do
    event.sequence_flows
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

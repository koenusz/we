defmodule WE.Event do
  use TypedStruct
  alias WE.{Event, SequenceFlow}

  @type event_type :: :start | :end | :message

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t())
    field :type, event_type(), default: :message
  end

  # accessors

  @spec event_in?([Task.t() | WE.Event.t()], Event.t()) :: boolean
  def event_in?(list, event) do
    list
    |> Enum.find(false, fn step ->
      if step.__struct__ == WE.Event and same_name?(step, event) do
        true
      end
    end)
  end

  @spec same_name?(Event.t(), Event.t()) :: boolean
  def same_name?(event1, event2) do
    event1.name == event2.name
  end

  @spec name(Event.t()) :: String.t()
  def name(event) do
    event.name
  end

  # construction

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

defmodule WE.State do
  use TypedStruct

  @type task_type :: :service | :human
  @type event_type :: :start | :end | :message
  @type state_type :: :task | :event

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :type, state_type(), default: :event
    field :content_type, task_type() | event_type(), default: :message
  end

  @spec service_task(String.t()) :: WE.State.t()
  def service_task(name) do
    %WE.State{name: name, type: :task, content_type: :service}
  end

  @spec human_task(String.t()) :: WE.State.t()
  def human_task(name) do
    %WE.State{name: name, type: :task, content_type: :service}
  end

  @spec message_event(String.t()) :: WE.State.t()
  def message_event(name) do
    %WE.State{name: name}
  end

  @spec start_event(String.t()) :: WE.State.t()
  def start_event(name) do
    %WE.State{name: name, content_type: :start}
  end

  @spec end_event(String.t()) :: WE.State.t()
  def end_event(name) do
    %WE.State{name: name, content_type: :end}
  end

  # utility fuctions

  @spec is_event!(WE.State.t()) :: boolean
  def is_event!(%WE.State{type: :event}) do
    true
  end

  def is_event!(state) do
    raise "#{state.name} is not an event"
  end

  @spec is_task!(WE.State.t()) :: boolean
  def is_task!(%WE.State{type: :task}) do
    true
  end

  def is_task!(state) do
    raise "#{state.name} is not an event"
  end

  @spec is_start_event?(WE.State.t()) :: boolean
  def is_start_event?(step) do
    step.type == :event and step.content_type == :start
  end

  @spec is_end_event?(WE.State.t()) :: boolean
  def is_end_event?(step) do
    step.type == :event and step.content_type == :end
  end

  @spec not_is_end_event?(WE.State.t()) :: boolean
  def not_is_end_event?(step) do
    step.type == :event and step.content_type != :end
  end

  @spec event_in?([WE.State.t()], WE.State.t()) :: boolean
  def event_in?(list, %WE.State{type: :event} = state) do
    list
    |> Enum.find(false, fn step ->
      same_name?(step, state)
    end)
  end

  @spec task_in?([WE.State.t()], WE.State.t()) :: boolean
  def task_in?(list, %WE.State{type: :task} = state) do
    list
    |> Enum.member?(state)
  end

  def task_in?(_list, _state) do
    false
  end

  @spec same_name?(WE.State.t(), WE.State.t()) :: boolean
  def same_name?(state1, state2) do
    state1.name == state2.name
  end

  @spec has_name?(WE.State.t(), String.t()) :: boolean
  def has_name?(state, name) do
    state.name == name
  end

  @spec name(WE.State.t()) :: String.t()
  def name(state) do
    state.name
  end

  @spec content_type(We.State.t()) :: atom
  def content_type(state) do
    state.content_type
  end
end

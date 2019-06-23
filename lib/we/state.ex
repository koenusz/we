defmodule WE.State do
  use TypedStruct

  @type task_type :: :service | :human
  @type event_type :: :start | :end | :message
  @type state_type :: :task | :event

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t()), default: []
    field :type, state_type(), default: :event
    field :contends_type, task_type() | event_type(), default: :message
    field :started, boolean, default: false
  end

  @spec service_task(String.t()) :: WE.State.t()
  def service_task(name) do
    %WE.State{name: name, type: :task, contends_type: :service}
  end

  @spec human_task(String.t()) :: WE.State.t()
  def human_task(name) do
    %WE.State{name: name, type: :task, contends_type: :service}
  end

  @spec message_event(String.t()) :: WE.State.t()
  def message_event(name) do
    %WE.State{name: name}
  end

  @spec start_event(String.t()) :: WE.State.t()
  def start_event(name) do
    %WE.State{name: name, contends_type: :start}
  end

  @spec end_event(String.t()) :: WE.State.t()
  def end_event(name) do
    %WE.State{name: name, contends_type: :end}
  end

  @spec add_sequence_flow(WE.State.t(), WE.SequenceFlow.t()) :: WE.State.t()
  def add_sequence_flow(state, sequence_flow) do
    %{state | sequence_flows: [sequence_flow | state.sequence_flows]}
  end

  # utility fuctions

  @spec event_in?(any, WE.State.t()) :: boolean
  def event_in?(list, %WE.State{type: :event} = state) do
    list
    |> Enum.find(false, fn step ->
      same_name?(step, state)
    end)
  end

  @spec task_in?(any, WE.State.t()) :: boolean
  def task_in?(list, %WE.State{type: :task} = state) do
    list
    |> Enum.find(false, fn step ->
      same_name?(step, state)
    end)
  end

  @spec same_name?(WE.State.t(), WE.State.t()) :: boolean
  def same_name?(state1, state2) do
    state1.name == state2.name
  end

  @spec name(WE.State.t()) :: String.t()
  def name(state) do
    state.name
  end

  @spec start_task(WE.State.t()) :: WE.State.t()
  def start_task(%WE.State{type: :task} = task) do
    %{task | started: true}
  end

  # TODO next  in task refactor
  @spec sequence_flows(WE.State.t()) :: [SequenceFlow.t()]
  def sequence_flows(state) do
    state.sequence_flows
  end

  # TODO renamed from flow-to
  @spec sequence_flows_by_names(WE.State.t(), [String.t()]) :: [SequenceFlow.t()]
  def sequence_flows_by_names(task, names) do
    names =
      case names do
        [] ->
          []

        [_h | _t] ->
          names

        _ ->
          [names]
      end
  end
end

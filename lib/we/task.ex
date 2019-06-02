defmodule WE.Task do
  use TypedStruct

  alias WE.{Task, SequenceFlow}

  @type task_type :: :service | :human

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t())
    field :type, task_type(), default: :service
    field :started, boolean, default: false
  end

  # accessors

  @spec task_in?([Task.t() | WE.Event.t()], Task.t()) :: boolean
  def task_in?(list, task) do
    list
    |> Enum.member?(task)
  end

  @spec same_name?(Task.t(), Task.t()) :: boolean
  def same_name?(task1, task2) do
    task1.name == task2.name
  end

  @spec name(Task.t()) :: String.t()
  def name(task) do
    task.name
  end

  @spec started(Task.t()) :: boolean
  def started(task) do
    task.started
  end

  # construction

  @spec start_task(Task.t()) :: Task.t()
  def start_task(task) do
    %{task | started: true}
  end

  @spec flow_to(Task.t(), [String.t()]) :: [SequenceFlow.t()]
  def flow_to(task, names) do
    names =
      case names do
        [] ->
          []

        [_h | _t] ->
          names

        _ ->
          [names]
      end

    task.sequence_flows
    |> Enum.filter(fn flow -> Enum.member?(names, flow.to) end)
  end

  @spec task(String.t(), [SequenceFlow.t()]) :: WE.Task.t()
  def task(name, sequence_flows) do
    %Task{name: name, sequence_flows: sequence_flows}
  end

  @spec next(Event.t()) :: :error | [SequenceFlow.t()]
  def next(event) do
    event.sequence_flows(@spec task(String.t(), fun()) :: WE.Task.t())
  end

  @spec add_sequence_flow(Task.t(), SequenceFlow.t()) :: Task.t()
  def add_sequence_flow(task, sequence_flow) do
    %{task | sequence_flows: [sequence_flow | task.sequence_flows]}
  end
end

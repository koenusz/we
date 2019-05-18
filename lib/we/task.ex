defmodule WE.Task do
  use TypedStruct

  alias WE.{Task, SequenceFlow}

  @type task_type :: :service | :human

  typedstruct enforce: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t())
    field :type, task_type(), default: :service
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

  @spec add_sequence_flow(%Task{}, SequenceFlow.t()) :: Task.t()
  def add_sequence_flow(task, sequence_flow) do
    %{task | sequence_flows: [sequence_flow | task.sequence_flows]}
  end
end

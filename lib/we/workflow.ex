defmodule WE.Workflow do
  use TypedStruct

  typedstruct enforce: true do
    field :name, String.t()
    field :steps, list(Task.t() | Event.t())
  end

  alias WE.{Workflow, Event, Task, Step, SequenceFlow}

  @spec get_start(%Workflow{}) :: %Event{} | :error
  def get_start(workflow) do
    workflow.steps
    |> Enum.find(:error, fn step -> step.type == :start end)
  end

  @spec get_next(%Workflow{}, String.t()) :: [Task.t() | Event.t()]
  def get_next(workflow, current_name) do
    workflow
    |> get_step_by_name(current_name)
    |> Step.next()
    |> Enum.map(fn sf -> get_step_by_name(workflow, sf.to) end)
  end

  @spec get_stops([Task.t() | Event.t()]) :: [Event.t()]
  def get_stops(steps) do
    steps
    |> Enum.filter(fn step -> step.type == :end end)
  end

  @spec get_next_steps_by_sequenceflows(Workflow.t(), [SequenceFlow.t()], %Task{}) ::
          [Task.t() | Event.t()]
  def get_next_steps_by_sequenceflows(workflow, sequenceflows, task) do
    case sequenceflows do
      [] ->
        task.sequence_flows
        |> SequenceFlow.get_default_flow()
        |> Enum.map(fn flow -> flow.to end)
        |> Enum.map(&get_step_by_name(workflow, &1))

      _ ->
        sequenceflows
        |> Enum.map(fn flow -> flow.to end)
        |> Enum.map(&get_step_by_name(workflow, &1))
    end
  end

  @spec get_step_by_name(Workflow.t(), String.t()) :: Task.t() | Event.t()
  def get_step_by_name(workflow, name) do
    workflow.steps
    |> Enum.find(:error, fn step -> step.name == name end)
  end

  @spec workflow(String.t(), list(%Task{} | %Event{})) :: WE.Workflow.t()
  def workflow(name, steps) do
    %Workflow{name: name, steps: steps}
  end

  @spec validate(Workflow.t()) :: :ok | [{:error, String.t()}]
  def validate(workflow) do
    result =
      []
      |> has_start?(workflow)
      |> has_end?(workflow)
      |> Enum.reject(fn item -> item == :ok end)

    case result do
      [] -> :ok
      x -> x
    end
  end

  defp has_start?(list, workflow) do
    test =
      workflow.steps
      |> Enum.map(&Map.get(&1, :type))
      |> Enum.member?(:start)

    if test do
      [:ok | list]
    else
      [{:error, "has no start event"} | list]
    end
  end

  defp has_end?(list, workflow) do
    test =
      workflow.steps
      |> Enum.map(&Map.get(&1, :type))
      |> Enum.member?(:end)

    if test do
      [:ok | list]
    else
      [{:error, "has no end event"} | list]
    end
  end

  # defp step_names_unique?() do
  # end

  # defp each_step_has_default_sequence_flow() do
  # end
end

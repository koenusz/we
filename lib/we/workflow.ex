defmodule WE.Workflow do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :steps, list(Task.t() | Event.t())
    field :documents, list({String.t(), String.t()}), default: []
  end

  alias WE.{Workflow, Event, Task, Step, SequenceFlow}

  @spec get_start(WE.Workflow.t()) :: WE.Event.t() | :error
  def get_start(workflow) do
    workflow.steps
    |> Enum.find(:error, fn step -> step.type == :start end)
  end

  @spec get_next(WE.Workflow.t(), String.t()) :: [Task.t() | Event.t()]
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

  @spec get_next_steps_by_sequenceflows(Workflow.t(), [SequenceFlow.t()], Task.t() | Event.t()) ::
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

  @spec get_task_by_name(Workflow.t(), String.t()) :: Task.t()
  def get_task_by_name(workflow, name) do
    get_step_by_name(workflow, name)
  end

  @spec get_step_by_name(Workflow.t(), String.t()) :: Task.t() | Event.t()
  def get_step_by_name(workflow, name) do
    workflow.steps
    |> Enum.find(:error, fn step -> step.name == name end)
  end

  @spec get_document(Workflow.t(), String.t()) :: WE.Document.t()
  def get_document(workflow, document_id) do
    workflow.documents
    |> Enum.find({:error, "not found"}, fn doc -> doc.id == document_id end)
  end

  @spec get_documents(Workflow.t()) :: [WE.Document.t()]
  def get_documents(workflow) do
    workflow.documents
  end

  @spec name(WE.Workflow.t()) :: String.t()
  def name(workflow) do
    workflow.name
  end

  def all_required_documents_present? (workflow, step) do
  end

  # create workflow
  @spec workflow(String.t(), list(WE.Task.t() | WE.Event.t())) :: WE.Workflow.t()
  def workflow(name, steps) do
    %Workflow{name: name, steps: steps}
  end

  @spec add_step(Workflow.t(), Task.t() | Event.t()) :: Workflow.t()
  def add_step(workflow, step) do
    %{workflow | steps: [step, workflow.steps]}
  end

  @spec add_document(Workflow.t(), WE.Document.t(), String.t()) :: Workflow.t()
  def add_document(workflow, document, step_name) do
    %{workflow | documents: [{WE.Document.document_id(document), step_name}, workflow.documents]}
  end

  @spec add_document(Workflow.t(), WE.Document.t()) :: Workflow.t()
  def add_document(workflow, document) do
    %{workflow | documents: [WE.Document.document_id(document), workflow.documents]}
  end
end

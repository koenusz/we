defmodule WE.Workflow do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :steps, list(WE.State.t())

    field :documents,
          list({String.t(), WE.Document.document_type(), String.t()}),
          default: []
  end

  @spec get_start(WE.Workflow.t()) :: WE.State.t() | :error
  def get_start(workflow) do
    workflow.steps
    |> Enum.find(:error, fn step -> step.type == :start end)
  end

  @spec get_next(WE.Workflow.t(), String.t()) :: [WE.State.t()]
  def get_next(workflow, current_name) do
    workflow
    |> get_step_by_name(current_name)
    |> WE.State.sequence_flows()
    |> Enum.map(fn sf -> get_step_by_name(workflow, sf.to) end)
  end

  @spec get_end_events([WE.State.t()]) :: [State.t()]
  def get_end_events(steps) do
    steps
    |> Enum.filter(fn step -> step.type == :end end)
  end

  @spec get_steps(WE.Workflow.t()) :: [WE.State.t()]
  def get_steps(workflow) do
    workflow.steps
  end

  @spec get_next_steps_by_sequenceflows(Workflow.t(), [SequenceFlow.t()], WE.State.t()) ::
          [WE.State.t()]
  def get_next_steps_by_sequenceflows(workflow, sequenceflows, task) do
    case sequenceflows do
      [] ->
        task.sequence_flows
        |> WE.SequenceFlow.get_default_flow()
        |> Enum.map(fn flow -> flow.to end)
        |> Enum.map(&get_step_by_name(workflow, &1))

      _ ->
        sequenceflows
        |> Enum.map(fn flow -> flow.to end)
        |> Enum.map(&get_step_by_name(workflow, &1))
    end
  end

  @spec get_step_by_name(Workflow.t(), String.t()) :: WE.State.t()
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

  @spec all_required_document_ids_for_step(WE.Workflow.t(), String.t()) :: [String.t()]
  def all_required_document_ids_for_step(workflow, step_name) do
    workflow
    |> all_required_document_ids()
    |> get_documents_by_step_name(step_name)
  end

  @spec all_required_document_ids(WE.Workflow.t()) :: [UUID.t()]
  def all_required_document_ids(workflow) do
    workflow.documents
    |> Enum.filter(fn doc ->
      {_, _, document_type} = doc
      document_type == :required
    end)
  end

  defp get_documents_by_step_name(documents, step_name) do
    documents
    |> Enum.filter(fn {_, _, doc_step_name} -> doc_step_name == step_name end)
  end

  # create workflow
  @spec workflow(String.t(), list(WE.State.t())) :: WE.Workflow.t()
  def workflow(name, steps) do
    %WE.Workflow{name: name, steps: steps}
  end

  @spec add_step(Workflow.t(), WE.State.t()) :: Workflow.t()
  def add_step(workflow, step) do
    %{workflow | steps: [step, workflow.steps]}
  end

  @spec add_document(Workflow.t(), WE.Document.t(), String.t()) :: Workflow.t()
  def add_document(workflow, document, step_name) do
    %{
      workflow
      | documents: [
          {WE.Document.document_id(document), WE.Document.document_type(document), step_name}
          | workflow.documents
        ]
    }
  end

  @spec add_document(Workflow.t(), WE.Document.t()) :: Workflow.t()
  def add_document(workflow, document) do
    %{
      workflow
      | documents: [
          {WE.Document.document_id(document), WE.Document.document_type(document), ""}
          | workflow.documents
        ]
    }
  end
end

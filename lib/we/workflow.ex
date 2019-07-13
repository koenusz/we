defmodule WE.Workflow do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :steps, list(WE.State.t()), default: []
    field :sequence_flows, list(WE.SequenceFlow.t()), default: []

    field :documents,
          list({String.t(), WE.Document.document_type(), String.t()}),
          default: []
  end

  @spec get_start_event!(WE.Workflow.t()) :: WE.State.t() | no_return
  def get_start_event!(workflow) do
    event =
      workflow.steps
      |> Enum.find(:error, &WE.State.is_start_event?(&1))

    if event == nil, do: raise(WE.WorkflowError, message: "No start event")
    event
  end

  @spec get_end_events([WE.State.t()]) :: [State.t()]
  def get_end_events(steps) do
    steps
    |> Enum.filter(&WE.State.is_end_event?(&1))
  end

  @spec get_steps(WE.Workflow.t()) :: [WE.State.t()]
  def get_steps(workflow) do
    workflow.steps
  end

  @spec get_next(WE.Workflow.t(), String.t()) :: [WE.State.t()]
  def get_next(workflow, current_name) do
    workflow.sequence_flows
    |> Enum.filter(&WE.SequenceFlow.from_equals(&1, current_name))
    |> Enum.map(&WE.SequenceFlow.to(&1))
    |> Enum.map(&WE.Workflow.get_step_by_name(workflow, &1))
    |> Enum.map(&WE.Helpers.unpack_ok_tuple(&1))
  end

  @spec get_next_steps_by_sequenceflows(Workflow.t(), [SequenceFlow.t()], WE.State.t()) ::
          [WE.State.t()]
  def get_next_steps_by_sequenceflows(workflow, sequenceflows, state) do
    case sequenceflows do
      [] ->
        get_next(workflow, WE.State.name(state))

      _ ->
        sequenceflows
        |> Enum.map(fn flow -> flow.to end)
        |> Enum.map(&get_step_by_name(workflow, &1))
        |> Enum.map(&WE.Helpers.unpack_ok_tuple(&1))
    end
  end

  @spec get_step_by_name(WE.Workflow.t(), String.t()) ::
          {:ok, WE.State.t()} | {:error, String.t()}
  def get_step_by_name(workflow, name) when is_binary(name) do
    workflow.steps
    |> Enum.find({:error, "step #{name} not found"}, &WE.State.has_name?(&1, name))
    |> WE.Helpers.ok_tuple()
  end

  @spec get_step_by_name(WE.Workflow.t(), WE.State.t()) :: WE.State.t()
  def get_step_by_name(workflow, state) do
    get_step_by_name(workflow, WE.State.name(state))
  end

  @spec get_document(WE.Workflow.t(), String.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  def get_document(workflow, document_id) do
    workflow.documents
    |> Enum.find({:error, "document not found"}, &WE.Document.has_id?(&1, document_id))
    |> WE.Helpers.ok_tuple()
  end

  @spec get_documents(WE.Workflow.t()) :: [WE.Document.t()]
  def get_documents(workflow) do
    workflow.documents
  end

  @spec sequence_flows(WE.Workflow.t()) :: [WE.SequenceFlow.t()]
  def sequence_flows(workflow) do
    workflow.sequence_flows
  end

  @spec name(WE.Workflow.t()) :: String.t()
  def name(workflow) do
    workflow.name
  end

  @spec all_required_document_ids_for_step(WE.Workflow.t(), String.t()) :: [String.t()]
  def all_required_document_ids_for_step(workflow, step_name) do
    workflow.documents
    |> Enum.filter(fn {_, document_type, _} -> document_type == :required end)
    |> Enum.filter(fn {_, _, doc_step_name} -> doc_step_name == step_name end)
  end

  @spec all_required_document_ids(WE.Workflow.t()) :: [UUID.t()]
  def all_required_document_ids(workflow) do
    workflow.documents
    |> Enum.filter(fn doc ->
      {_, _, document_type} = doc
      document_type == :required
    end)
  end

  # create workflow
  @spec workflow(String.t()) :: WE.Workflow.t()
  def workflow(name) do
    %WE.Workflow{name: name}
  end

  @spec add_service_task(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_service_task(workflow, name) do
    %{workflow | steps: [WE.State.service_task(name) | workflow.steps]}
  end

  @spec add_human_task(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_human_task(workflow, name) do
    %{workflow | steps: [WE.State.human_task(name) | workflow.steps]}
  end

  @spec add_message_event(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_message_event(workflow, name) do
    %{workflow | steps: [WE.State.message_event(name) | workflow.steps]}
  end

  @spec add_start_event(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_start_event(workflow, name) do
    %{workflow | steps: [WE.State.start_event(name) | workflow.steps]}
  end

  @spec add_end_event(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_end_event(workflow, name) do
    %{workflow | steps: [WE.State.end_event(name) | workflow.steps]}
  end

  @spec add_default_sequence_flow(WE.Workflow.t(), String.t(), String.t()) :: WE.Workflow.t()
  def add_default_sequence_flow(workflow, from, to) do
    flow = WE.SequenceFlow.default(from, to)
    %{workflow | sequence_flows: [flow | workflow.sequence_flows]}
  end

  @spec add_sequence_flow(WE.Workflow.t(), String.t(), String.t()) :: WE.Workflow.t()
  def add_sequence_flow(workflow, from, to) do
    flow = WE.SequenceFlow.sequence_flow(from, to)
    %{workflow | sequence_flows: [flow | workflow.sequence_flows]}
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

defmodule WE.WorkflowError do
  defexception message: "Workflow error"
end

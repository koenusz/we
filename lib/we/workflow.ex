defmodule WE.Workflow do
  use TypedStruct

  @moduledoc """
    The workflow module is a module used for describing a workflow. A workflow is a collection of steps
    tied together by sequence flows. There are two types of steps. These are events and tasks. An event is
    a step where the workflow is notified of something. It is a single point in time.
    A task is a step with a start, an end and a duration.
  """
  @moduledoc since: "0.1.0"

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :steps, list(WE.State.t()), default: []
    field :sequence_flows, list(WE.SequenceFlow.t()), default: []

    field :document_references,
          list(WE.DocumentReference.t()),
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

  @spec get_document_reference(WE.Workflow.t(), String.t()) ::
          {:ok, WE.DocumentReference.t()} | {:error, String.t()}
  def get_document_reference(workflow, document_id) do
    workflow.document_references
    |> Enum.find({:error, "document not found"}, &WE.DocumentReference.has_name?(&1, document_id))
    |> WE.Helpers.ok_tuple()
  end

  @spec get_document_references(WE.Workflow.t()) :: [WE.DocumentReference.t()]
  def get_document_references(workflow) do
    workflow.document_references
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
    workflow.document_references
    |> Enum.filter(&WE.DocumentReference.is_required?(&1))
    |> Enum.filter(&WE.DocumentReference.has_step?(&1, step_name))
    |> Enum.map(&WE.DocumentReference.name(&1))
  end

  @spec all_required_document_ids(WE.Workflow.t()) :: [String.t()]
  def all_required_document_ids(workflow) do
    workflow.document_references
    |> Enum.filter(&WE.DocumentReference.is_required?(&1))
  end

  # create workflow

  @doc """
    Create a workflow.
  """
  @doc since: "0.1.0"
  @spec workflow(String.t()) :: WE.Workflow.t()
  def workflow(name) do
    %WE.Workflow{name: name}
  end

  @doc """
    Add a service task. This is something a system does.
  """
  @doc since: "0.1.0"
  @spec add_service_task(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_service_task(workflow, name) do
    %{workflow | steps: [WE.State.service_task(name) | workflow.steps]}
  end

  @doc """
    Add a human task. This is something a human does.
  """
  @doc since: "0.1.0"
  @spec add_human_task(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_human_task(workflow, name) do
    %{workflow | steps: [WE.State.human_task(name) | workflow.steps]}
  end

  @doc """
    The workflow receives a message.
  """
  @doc since: "0.1.0"
  @spec add_message_event(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_message_event(workflow, name) do
    %{workflow | steps: [WE.State.message_event(name) | workflow.steps]}
  end

  @doc """
    Add a starting point for a workflow.
  """
  @doc since: "0.1.0"
  @spec add_start_event(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_start_event(workflow, name) do
    %{workflow | steps: [WE.State.start_event(name) | workflow.steps]}
  end

  @doc """
    Add an endpoint for a workflow
  """
  @doc since: "0.1.0"
  @spec add_end_event(WE.Workflow.t(), String.t()) :: WE.Workflow.t()
  def add_end_event(workflow, name) do
    %{workflow | steps: [WE.State.end_event(name) | workflow.steps]}
  end

  @doc """
    Connect two steps to eachother by adding a sequence flow. Each step should always have one and only one outgoing
    default sequence flow. (except stop events)
  """
  @doc since: "0.1.0"
  @spec add_default_sequence_flow(WE.Workflow.t(), String.t(), String.t()) :: WE.Workflow.t()
  def add_default_sequence_flow(workflow, from, to) do
    flow = WE.SequenceFlow.default(from, to)
    %{workflow | sequence_flows: [flow | workflow.sequence_flows]}
  end

  @doc """
    Add a non-default sequence flow. This is used when a step needs more than 1 outgoing sequence flow.
  """
  @doc since: "0.1.0"
  @spec add_sequence_flow(WE.Workflow.t(), String.t(), String.t()) :: WE.Workflow.t()
  def add_sequence_flow(workflow, from, to) do
    flow = WE.SequenceFlow.sequence_flow(from, to)
    %{workflow | sequence_flows: [flow | workflow.sequence_flows]}
  end

  @doc """
    Add a document to a step. When the step is empty the document will be added to the workflow instead.
    Only one document can be added per step or one per workfow when added without a name.
  """
  @doc since: "0.1.0"
  @spec add_document(Workflow.t(), WE.Document.t(), String.t()) :: Workflow.t() | no_return
  def add_document(workflow, document, step_name \\ "") do
    workflow.document_references
    |> Enum.any?(&WE.DocumentReference.has_step?(&1, step_name))
    |> case do
      true ->
        raise WE.WorkflowError, message: "step '#{step_name}' already has a document"

      _ ->
        %{
          workflow
          | document_references: [
              WE.DocumentReference.document_reference(document, step_name)
              | workflow.document_references
            ]
        }
    end
  end
end

defmodule WE.WorkflowError do
  defexception message: "Workflow error"
end

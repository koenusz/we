defmodule WE do
  @moduledoc """
    This is the WorkflowEngine api module.
    For more info see the [README](readme.html)

    The business id is a unique identifier, chosen form the problem domain of the
    application wherein this library is used. It serves to both uniquely identify a
    workflow, but also to create a connection between the application domain and the workflow engine.

  """
  @moduledoc since: "0.1.0"

  @doc """
  Initialise a workflow engine. The engine is identified by a business_id.
  This is a unique identifier to identify the engine with. Use this id as a means of
  connecting your business domain to a workflow.
  """
  @doc since: "0.1.0"
  def init_engine(business_id, workflow) do
    WE.EngineSupervisor.add_engine(
      business_id,
      workflow
    )
  end

  @doc """
    Start executing a workflow engine.
  """
  @doc since: "0.1.0"
  def start_engine(business_id) do
    WE.Engine.start_execution(business_id)
  end

  @doc """
    Send an event to the workflow. In case there are more outgoing sequence flows than
    the default it is possible to follow an other outgoing flow (or multiple). This is done
    by defining the next state of the engine by passing a list of the next states.
  """
  @doc since: "0.1.0"
  def handle_event(business_id, event_name, next_steps \\ []) do
    WE.Engine.message_event(business_id, event_name, next_steps)
  end

  @doc """
    Start a task step
  """
  @doc since: "0.1.0"
  def start_task(business_id, task_name) do
    WE.Engine.start_task(business_id, task_name)
  end

  @doc """
    complete a task step.

    Make sure that any required documents are added or else the task cannot be completed.
  """
  @doc since: "0.1.0"
  def complete_task(business_id, task_name, next_steps \\ []) do
    WE.Engine.complete_task(business_id, task_name, next_steps)
  end

  @doc """
    Ask the engine for its current state. These are the steps that the engine is able to resolve
  """
  @doc since: "0.1.0"
  def current_state(business_id) do
    WE.Engine.current_state(business_id)
  end

  @doc """
    Retrieve the workflow's history.
  """
  @doc since: "0.1.0"
  def history(business_id) do
    WE.Engine.history(business_id)
  end

  # documents
  @doc """
    Store a document.

  """
  @doc since: "0.1.0"
  def store_document(business_id, document_name, data) do
    {:ok, history_id, document} = WE.Engine.create_document(business_id, document_name, data)
    WE.DocumentLibrary.store_document(history_id, document)
  end

  @doc """
    Update a document
  """
  @doc since: "0.1.0"
  def update_document(business_id, document_name, data) do
    {:ok, history_id, document} = WE.Engine.create_document(business_id, document_name, data)
    WE.DocumentLibrary.update_document(history_id, document)
  end

  @doc """
    Retrieve a document.
  """
  @doc since: "0.1.0"
  def get_document(business_id, document_name) do
    history_id(business_id)
    |> WE.DocumentLibrary.get_document(document_name)
  end

  @doc """
    Retrieve all documents that are stored on this workflow.
  """
  @doc since: "0.1.0"
  def all_documents(business_id) do
    history_id(business_id)
    |> WE.DocumentLibrary.all_documents()
  end

  defp history_id(business_id) do
    WE.Engine.history(business_id)
    |> elem(2)
    |> WE.WorkflowHistory.id()
  end
end

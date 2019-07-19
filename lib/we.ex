defmodule WE do
  @moduledoc """
    This is the WorkflowEngine api module.
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
  end

  @doc """
    Send an event to the workflow. In case there are more outgoing sequence flows than
    the default it is possible to follow an other outgoing flow (or multiple). This is done
    by defining the next state of the engine by passing a list of the next states.
  """
  @doc since: "0.1.0"
  def receive_event(business_id, event_name, next_steps \\ []) do
  end

  @doc """
    Start a task step
  """
  @doc since: "0.1.0"
  def start_task(business_id, task_name) do
  end

  @doc """
    complete a task step.

    Make sure that any required documents are added or else the task cannot be completed.
  """
  @doc since: "0.1.0"
  def complete_task(business_id, task_name, next_steps \\ []) do
  end

  @doc """
    Ask the engine for its current state. These are the steps that the engine is able to resolve
  """
  @doc since: "0.1.0"
  def current_state(business_id) do
  end

  @doc """
    Retrieve the workflow's history.
  """
  @doc since: "0.1.0"
  def history(business_id) do
  end

  # documents
  @doc """
    Store a document.

  """
  @doc since: "0.1.0"
  def store_document(business_id, document_name, data) do
  end

  @doc """
    Update a document
  """
  @doc since: "0.1.0"
  def update_document(business_id, document_name, data) do
  end

  @doc """
    Retrieve a document.
  """
  @doc since: "0.1.0"
  def get_document(business_id, document_name) do
  end

  @doc """
    Retrieve all documents that are stored on this workflow.
  """
  @doc since: "0.1.0"
  def all_documents(business_id) do
  end
end

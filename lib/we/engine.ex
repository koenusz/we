defmodule WE.Engine do
  use GenServer
  # todo move to gen statem
  use TypedStruct
  alias WE.{Workflow, WorkflowHistory}

  typedstruct enforce: true, opaque: true do
    field :current, [State.t()]
  end

  @impl GenServer
  @spec init({WE.Workflow.t(), [module()]}, [any()]) ::
          {:ok, {WE.WorkflowHistory.t()}}
  def init({workflow, storage_adapters}, _opts \\ []) do
    WE.WorkflowValidator.validate(workflow)
    {:ok, {WorkflowHistory.init(workflow, storage_adapters)}}
  end

  @impl GenServer
  def handle_call(:start, _from, {history}) do
    workflow = WE.WorkflowHistory.workflow(history)

    WE.DocumentSupervisor.add_library(
      WE.WorkflowHistory.history_id(history),
      workflow,
      WE.WorkflowHistory.storage_adapters(history)
    )

    event = Workflow.get_start_event!(workflow)
    history = WorkflowHistory.record_event!(history, event)
    next_list = Workflow.get_next(workflow, WE.State.name(event))

    reply_or_end({history, next_list})
  end

  @impl GenServer
  def handle_call(:start, _from, {history, current}) do
    {:reply, {:error, "already started"}, {history, current}}
  end

  @impl GenServer
  def handle_call({:start_task, task_name}, _from, {history, current}) do
    workflow = WE.WorkflowHistory.workflow(history)
    {:ok, task} = Workflow.get_step_by_name(workflow, task_name)

    history =
      cond do
        WE.WorkflowHistory.task_started?(history, WE.State.name(task)) ->
          WE.WorkflowHistory.record_task_error(history, task, "already started")

        not WE.State.task_in?(current, task) ->
          WE.WorkflowHistory.record_task_error(history, task, "task not in current state")

        true ->
          WE.WorkflowHistory.record_task_start!(history, task)
      end

    {:reply, :ok, {history, current}}
  end

  @impl GenServer
  def handle_call({:complete_task, task_name, sequenceflows}, _from, {history, current}) do
    workflow = WE.WorkflowHistory.workflow(history)
    {:ok, task} = Workflow.get_step_by_name(workflow, task_name)
    WE.State.is_task!(task)

    {history, next_list} =
      cond do
        not WE.State.task_in?(current, task) ->
          {WE.WorkflowHistory.record_task_error(history, task, "task not in current state"),
           current}

        not WE.DocumentLibrary.all_required_documents_present?(
          WE.WorkflowHistory.history_id(history),
          WE.State.name(task)
        ) ->
          {WE.WorkflowHistory.record_task_error(
             history,
             task,
             "not all required documents present"
           ), current}

        true ->
          {WorkflowHistory.record_task_complete!(history, task),
           Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, task)}
      end

    reply_or_end({history, next_list})
  end

  @impl GenServer
  def handle_call({:message_event, event, sequenceflows}, _from, {history, current}) do
    workflow = WE.WorkflowHistory.workflow(history)

    {history, next_list} =
      cond do
        not WE.State.event_in?(current, event) ->
          {WE.WorkflowHistory.record_event_error(
             history,
             event,
             "event not in current state"
           ), current}

        not WE.DocumentLibrary.all_required_documents_present?(
          WE.WorkflowHistory.history_id(history),
          WE.State.name(event)
        ) ->
          {WE.WorkflowHistory.record_event_error(
             history,
             event,
             "not all required documents present"
           ), current}

        true ->
          {WorkflowHistory.record_event!(history, event),
           Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, event)}
      end

    reply_or_end({history, next_list})
  end

  @impl GenServer
  def handle_call(:current_state, _from, {history, current}) do
    {:reply, {:ok, current}, {history, current}}
  end

  @impl GenServer
  def handle_call(:history, _from, {history, current}) do
    {:reply, {:ok, history}, {history, current}}
  end

  defp reply_or_end({history, next_list}) do
    case Workflow.get_end_events(next_list) do
      [] ->
        {:reply, :ok, {history, next_list}}

      stops ->
        history = WorkflowHistory.record_event!(history, Enum.at(stops, 0))
        {:reply, :ok, {history, next_list}}
    end
  end

  # client

  @spec start_link(WE.Workflow.t(), [WE.StorageProvider.t()]) ::
          :ignore | {:error, any()} | {:ok, pid()}
  def start_link(workflow, storage_adapters \\ []) do
    GenServer.start_link(__MODULE__, {workflow, storage_adapters})
  end

  @spec start_execution(pid) :: pid
  def start_execution(engine) do
    :ok = GenServer.call(engine, :start)
    engine
  end

  @spec message_event(pid, State.t(), [WE.SequenceFlow.t()]) :: pid
  def message_event(engine, event, sequenceflows \\ []) do
    :ok = GenServer.call(engine, {:message_event, event, sequenceflows})
    engine
  end

  @spec start_task(pid, String.t()) :: pid
  def start_task(engine, task) when is_binary(task) do
    :ok = GenServer.call(engine, {:start_task, task})
    engine
  end

  @spec start_task(pid, WE.State.t()) :: pid
  def start_task(engine, task) do
    WE.State.is_task!(task)
    :ok = GenServer.call(engine, {:start_task, WE.State.name(task)})
    engine
  end

  @spec complete_task(pid, String.t(), [WE.SequenceFlow.t()]) :: pid
  def complete_task(engine, task, sequenceflows \\ []) do
    :ok = GenServer.call(engine, {:complete_task, task, sequenceflows})
    engine
  end

  @spec current_state(pid()) :: {:ok, pid, term()}
  def current_state(engine) do
    {:ok, current_state} = GenServer.call(engine, :current_state)
    {:ok, engine, current_state}
  end

  @spec history(pid()) :: {:ok, pid, WE.WorkflowHistory.t()}
  def history(engine) do
    {:ok, history} = GenServer.call(engine, :history)
    {:ok, engine, history}
  end
end

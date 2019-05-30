defmodule WE.Engine do
  use GenServer
  use TypedStruct
  alias WE.{Workflow, WorkflowHistory}

  typedstruct enforce: true, opaque: true do
    field :current, [Event.t() | Task.t()]
  end

  @impl GenServer
  @spec init({WE.Workflow.t(), [module()]}, [any()]) ::
          {:ok, {WE.Workflow.t(), WE.WorkflowHistory.t()}}
  def init({workflow, storage_providers}, _opts \\ []) do
    {:ok, {workflow, WorkflowHistory.init(WE.Workflow.name(workflow), storage_providers)}}
  end

  @impl GenServer
  def handle_call(:start, _from, {workflow, history}) do
    event = Workflow.get_start(workflow)
    history = WorkflowHistory.record_event(history, event)
    next_list = Workflow.get_next(workflow, WE.Event.name(event))
    reply_or_end({workflow, history, next_list})
  end

  @impl GenServer
  def handle_call(:start, _from, {workflow, history, current}) do
    {:reply, {:error, "already started"}, {workflow, history, current}}
  end

  @impl GenServer
  def handle_call({:start_task, task_name}, _from, {workflow, history, current}) do
    task = Workflow.get_step_by_name(workflow, task_name)

    if Enum.member?(current, task) and not WE.Task.started(task) do
      current =
        current
        |> Enum.map(fn step ->
          if step == task do
            WE.Task.start_task(step)
          else
            step
          end
        end)

      history = WorkflowHistory.record_task_start(history, task)
      {:reply, :ok, {workflow, history, current}}
    else
      {:reply, {:error, "task not in current state"}, {workflow, history, current}}
    end
  end

  @impl GenServer
  def handle_call({:complete_task, task_name, sequenceflows}, _from, {workflow, history, current}) do
    task = Workflow.get_task_by_name(workflow, task_name)

    if WE.Task.task_in?(current, task) do
      history = WorkflowHistory.record_task_complete(history, task)
      next_list = Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, task)
      reply_or_end({workflow, history, next_list})
    else
      {:reply, {:error, "task not in current state"}, {workflow, history, current}}
    end
  end

  @impl GenServer
  def handle_call({:message_event, event, sequenceflows}, _from, {workflow, history, current}) do
    if WE.Event.event_in?(current, event) do
      history = WorkflowHistory.record_event(history, event)
      next_list = Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, event)
      reply_or_end({workflow, history, next_list})
    else
      {:reply, {:error, "event not in current state"}, {workflow, history, current}}
    end
  end

  @impl GenServer
  def handle_call(:current_state, _from, {workflow, history, current}) do
    {:reply, {:ok, current}, {workflow, history, current}}
  end

  @impl GenServer
  def handle_call(:history, _from, {workflow, history, current}) do
    {:reply, {:ok, history}, {workflow, history, current}}
  end

  defp reply_or_end({workflow, history, next_list}) do
    case Workflow.get_stops(next_list) do
      [] ->
        {:reply, :ok, {workflow, history, next_list}}

      stops ->
        history = WorkflowHistory.record_event(history, Enum.at(stops, 0))
        {:reply, :ok, {workflow, history, next_list}}
    end
  end

  # client

  @spec start_link(WE.Workflow.t(), [WE.StorageProvider.t()]) ::
          :ignore | {:error, any()} | {:ok, pid()}
  def start_link(workflow, storage_providers \\ []) do
    GenServer.start_link(__MODULE__, {workflow, storage_providers})
  end

  @spec start_execution(pid) :: pid
  def start_execution(engine) do
    :ok = GenServer.call(engine, :start)
    engine
  end

  @spec message_event(pid, Event.t(), [WE.SequenceFlow.t()]) :: pid
  def message_event(engine, event, sequenceflows \\ []) do
    :ok = GenServer.call(engine, {:message_event, event, sequenceflows})
    engine
  end

  @spec start_task(pid, String.t()) :: pid
  def start_task(engine, task) do
    :ok = GenServer.call(engine, {:start_task, task})
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

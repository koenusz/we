defmodule WE.Engine do
  use GenServer
  use TypedStruct
  alias WE.{Workflow, WorkflowHistory}

  typedstruct enforce: true, opaque: true do
    field :current, [Event.t() | Task.t()]
  end

  @impl GenServer
  @spec init(%Workflow{}, any()) :: {:ok, {%Workflow{}, any()}}
  def init(workflow, _opts \\ []) do
    {:ok, {workflow, WorkflowHistory.init(workflow.name)}}
  end

  @impl GenServer
  def handle_call(:start, _from, {workflow, history}) do
    event = Workflow.get_start(workflow)
    history = WorkflowHistory.record_event(history, event)
    next_list = Workflow.get_next(workflow, event.name)
    reply_or_end({workflow, history, next_list})
  end

  @impl GenServer
  def handle_call(:start, _from, {workflow, history, current}) do
    {:reply, {:error, "already started"}, {workflow, history, current}}
  end

  @impl GenServer
  def handle_call({:start_task, task}, _from, {workflow, history, current}) do
    if Enum.member?(current, task) and !task.started do
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
  def handle_call({:complete_task, task, sequenceflows}, _from, {workflow, history, current}) do
    if Enum.member?(current, task) do
      history = WorkflowHistory.record_task_complete(history, task)
      next_list = Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, task)
      reply_or_end({workflow, history, next_list})
    else
      {:reply, {:error, "task not in current state"}, {workflow, history, current}}
    end
  end

  @impl GenServer
  def handle_call({:message_event, event, sequenceflows}, _from, {workflow, history, current}) do
    if Enum.member?(current, event) do
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

  def start_link(workflow) do
    GenServer.start_link(__MODULE__, workflow)
  end

  @spec start_execution(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  def start_execution(engine) do
    GenServer.call(engine, :start)
  end

  def message_event(engine, event, sequenceflows \\ []) do
    GenServer.call(engine, {:message_event, event, sequenceflows})
  end

  def start_task(engine, task) do
    GenServer.call(engine, {:start_task, task})
  end

  def complete_task(engine, task, sequenceflows \\ []) do
    GenServer.call(engine, {:complete_task, task, sequenceflows})
  end

  @spec current_state(pid()) :: any()
  def current_state(engine) do
    GenServer.call(engine, :current_state)
  end

  @spec history(pid()) :: any()
  def history(engine) do
    GenServer.call(engine, :history)
  end
end

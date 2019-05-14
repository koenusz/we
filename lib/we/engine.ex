defmodule WE.Engine do
  use GenServer
  alias WE.{Workflow, WorkflowHistory}

  @impl GenServer
  @spec init(%Workflow{}, any()) :: {:ok, {%Workflow{}, any()}}
  def init(workflow, _opts \\ []) do
    {:ok, {workflow, WorkflowHistory.init(workflow.name)}}
  end

  @impl GenServer
  def handle_call({:start, data}, _from, {workflow, history}) do
    event = Workflow.get_start(workflow)
    history = WorkflowHistory.record_event(history, event.name)
    next_list = Workflow.get_next(workflow, event.name, data)

    {:reply, history, {workflow, history, data}, {:continue, {:step, next_list}}}
  end

  @impl GenServer
  def handle_call(:start_task, {workflow, history, data}) do
  end

  @impl GenServer
  def handle_call({:complete, data}, {workflow, state}) do
  end

  @impl GenServer
  def handle_call(:current, {workflow, state}) do
  end

  @impl GenServer
  def handle_call(:event, {workflow, state}) do
  end

  @impl GenServer
  def handle_call(:history, {workflow, state}) do
    state
  end

  @impl GenServer
  @spec handle_continue(
          :task | {:step, [Task.t() | Event.t()]},
          {Workflow.t(), WorkflowHistory.t(), any()}
        ) ::
          {:noreply, {Workflow.t(), WorkflowHistory.t(), any()}}
          | {:noreply, any(), {Workflow.t(), WorkflowHistory.t(), any()},
             {:continue, {:step, any()}}}
  def handle_continue({:step, steps}, {workflow, history, data}) do
    case steps do
      [] ->
        {:noreply, {workflow, history, data}}

      [head | tail] ->
        history =
          case head.__struct__ do
            WE.Task -> WorkflowHistory.record_task(history, head.name) |> IO.inspect()
            WE.Event -> WorkflowHistory.record_event(history, head.name) |> IO.inspect()
          end

        {:noreply, history, {workflow, history, data}, {:continue, {:step, tail}}}
    end
  end

  @impl GenServer
  def handle_continue(:task, {workflow, state}) do
  end

  # client

  def start_link(workflow) do
    GenServer.start_link(__MODULE__, workflow)
  end

  def start(server, data \\ %{}) do
    GenServer.call(server, {:start, data})
  end

  def completeStep(server, data) do
    GenServer.call(server, {:complete, data})
  end
end

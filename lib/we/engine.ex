defmodule WE.Engine do
  use GenServer
  use TypedStruct

  @impl GenServer
  @spec init({WE.Workflow.t(), [module()]}, [any()]) ::
          {:ok, WE.WorkflowHistory.t(), [WE.State.t()]}
  def init({business_id, workflow, storage_adapters}, _opts \\ []) do
    WE.WorkflowValidator.validate(workflow)

    history = WE.WorkflowHistory.init(business_id, workflow, storage_adapters)

    WE.DocumentSupervisor.add_library(
      business_id,
      workflow,
      WE.WorkflowHistory.storage_adapters(history)
    )

    {:ok, {history, []}}
  end

  @impl GenServer
  def handle_call(:start, _from, {history, []}) do
    workflow = WE.WorkflowHistory.workflow(history)

    event = WE.Workflow.get_start_event!(workflow)
    history = WE.WorkflowHistory.record_event!(history, event)
    next_list = WE.Workflow.get_next(workflow, WE.State.name(event))

    reply_or_end({history, next_list})
  end

  @impl GenServer
  def handle_call(:start, _from, {history, current}) do
    {:reply, {:error, "already started"}, {history, current}}
  end

  @impl GenServer
  def handle_call({:start_task, task_name}, _from, {history, current}) do
    workflow = WE.WorkflowHistory.workflow(history)
    {:ok, task} = WE.Workflow.get_step_by_name(workflow, task_name)

    history =
      cond do
        WE.WorkflowHistory.task_started?(history, WE.State.name(task)) ->
          WE.WorkflowHistory.record_task_error(history, task, "already started")

        not WE.State.task_in?(current, task) ->
          WE.WorkflowHistory.record_task_error(
            history,
            task,
            "task #{task_name} not in current state"
          )

        true ->
          WE.WorkflowHistory.record_task_start!(history, task)
      end

    {:reply, :ok, {history, current}}
  end

  @impl GenServer
  def handle_call({:complete_task, task_name, sequenceflows}, _from, {history, current}) do
    workflow = WE.WorkflowHistory.workflow(history)
    {:ok, task} = WE.Workflow.get_step_by_name(workflow, task_name)
    WE.State.is_task!(task)

    {history, next_list} =
      cond do
        not WE.State.task_in?(current, task) ->
          {WE.WorkflowHistory.record_task_error(
             history,
             task,
             "task #{task_name} not in current state"
           ), current}

        not WE.DocumentLibrary.all_required_documents_present?(
          WE.WorkflowHistory.id(history),
          WE.State.name(task)
        ) ->
          {WE.WorkflowHistory.record_task_error(
             history,
             task,
             "not all required documents present"
           ), current}

        true ->
          {WE.WorkflowHistory.record_task_complete!(history, task),
           WE.Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, task)}
      end

    reply_or_end({history, next_list})
  end

  @impl GenServer
  def handle_call({:message_event, event_name, sequenceflows}, _from, {history, current}) do
    workflow = WE.WorkflowHistory.workflow(history)
    {:ok, event} = WE.Workflow.get_step_by_name(workflow, event_name)
    WE.State.is_event!(event)

    {history, next_list} =
      cond do
        not WE.State.event_in?(current, event) ->
          {WE.WorkflowHistory.record_event_error(
             history,
             event,
             "event not in current state"
           ), current}

        not WE.DocumentLibrary.all_required_documents_present?(
          WE.WorkflowHistory.id(history),
          WE.State.name(event)
        ) ->
          {WE.WorkflowHistory.record_event_error(
             history,
             event,
             "not all required documents present"
           ), current}

        true ->
          {WE.WorkflowHistory.record_event!(history, event),
           WE.Workflow.get_next_steps_by_sequenceflows(workflow, sequenceflows, event)}
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
    case WE.Workflow.get_end_events(next_list) do
      [] ->
        {:reply, :ok, {history, next_list}}

      stops ->
        history = WE.WorkflowHistory.record_event!(history, Enum.at(stops, 0))
        {:reply, :ok, {history, next_list}}
    end
  end

  # client

  @spec start_link([module()], [...]) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(storage_adapters, [business_id, workflow]) do
    start_link(storage_adapters, business_id, workflow)
  end

  @spec start_link([module()], String.t(), WE.Workflow.t()) ::
          :ignore | {:error, any} | {:ok, pid}
  def start_link(storage_adapters, business_id, workflow) do
    GenServer.start_link(__MODULE__, {business_id, workflow, storage_adapters},
      name: via_tuple(business_id)
    )
  end

  @spec start_execution(String.t()) :: String.t()
  def start_execution(business_id) do
    :ok = GenServer.call(via_tuple(business_id), :start)
    business_id
  end

  @spec message_event(String.t(), String.t(), [WE.SequenceFlow.t()]) :: String.t()
  def message_event(business_id, event_name, sequenceflows \\ []) when is_binary(event_name) do
    :ok = GenServer.call(via_tuple(business_id), {:message_event, event_name, sequenceflows})

    business_id
  end

  @spec start_task(String.t(), String.t()) :: String.t()
  def start_task(business_id, task) when is_binary(task) do
    :ok = GenServer.call(via_tuple(business_id), {:start_task, task})
    business_id
  end

  @spec start_task(String.t(), WE.State.t()) :: String.t()
  def start_task(business_id, task) do
    WE.State.is_task!(task)
    :ok = GenServer.call(via_tuple(business_id), {:start_task, WE.State.name(task)})
    business_id
  end

  @spec complete_task(String.t(), String.t(), [WE.SequenceFlow.t()]) :: String.t()
  def complete_task(business_id, task, sequenceflows \\ []) do
    :ok = GenServer.call(via_tuple(business_id), {:complete_task, task, sequenceflows})
    business_id
  end

  @spec current_state(String.t()) :: {:ok, String.t(), term()}
  def current_state(business_id) do
    {:ok, current_state} = GenServer.call(via_tuple(business_id), :current_state)
    {:ok, business_id, current_state}
  end

  @spec history(String.t()) :: {:ok, String.t(), WE.WorkflowHistory.t()}
  def history(business_id) do
    {:ok, history} = GenServer.call(via_tuple(business_id), :history)
    {:ok, business_id, history}
  end

  @spec create_document(String.t(), String.t(), map()) :: {:ok, String.t(), WE.Document.t()}
  def create_document(business_id, document_name, data) do
    {:ok, history} = GenServer.call(via_tuple(business_id), :history)

    document =
      history
      |> WE.WorkflowHistory.workflow()
      |> WE.Workflow.get_document_reference(document_name)
      |> elem(1)
      |> WE.Document.from_reference()
      |> WE.Document.update_data(data)

    {:ok, WE.WorkflowHistory.id(history), document}
  end

  # registry lookup handler
  defp via_tuple(business_id), do: {:via, Registry, {:engine_registry, business_id}}
end

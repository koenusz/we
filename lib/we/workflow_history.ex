defmodule WE.WorkflowHistory do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :id, UUID.t(), default: UUID.uuid1()
    field :workflow, WE.Workflow.t()
    field :records, list(WE.HistoryRecord.t()), default: []
    field :storage_adapters, [atom]
  end

  @spec init(WE.Workflow.t(), [WE.StorageAdapter.t()]) :: WE.WorkflowHistory.t()
  def init(workflow, storage_adapters) do
    %WE.WorkflowHistory{workflow: workflow, storage_adapters: storage_adapters}
  end

  @spec history_id(WE.WorkflowHistory.t()) :: UUID.t()
  def history_id(history) do
    history.id
  end

  @spec storage_adapters(WE.WorkflowHistory.t()) :: [atom]
  def storage_adapters(history) do
    history.storage_adapters
  end

  @spec record_task_start(WorkflowHistory.t(), WE.Task.t()) :: WorkflowHistory.t()
  def record_task_start(history, task) do
    record = WE.HistoryRecord.record_task_start(task)
    update_records(history, record)
  end

  @spec record_task_complete(WorkflowHistory.t(), WE.Task.t()) :: WorkflowHistory.t()
  def record_task_complete(history, task) do
    record = WE.HistoryRecord.record_task_complete(task)
    update_records(history, record)
  end

  @spec record_event(WorkflowHistory.t(), Event.t()) :: WorkflowHistory.t()
  def record_event(history, event) do
    record = WE.HistoryRecord.record_event(event)
    update_records(history, record)
  end

  @spec record_document(WorkflowHistory.t(), WE.Document.t()) :: WorkflowHistory.t()
  def record_document(history, doc) do
    record = WE.HistoryRecord.record_document(doc)
    update_records(history, record)
  end

  @spec task_has_required_documents(WE.WorkflowHistory.t(), WE.Task.t()) :: boolean
  def task_has_required_documents(history, task) do
    WE.Workflow.all_document_ids_for_task(history.workflow, task)
    |> Enum.all?(fn id ->
      Enum.any?(history.records, &WE.HistoryRecord.has_document_id?(&1, id))
    end)
  end

  @spec record_message_error(WE.WorkflowHistory.t(), String.t() | {:error, String.t()}) ::
          WE.WorkflowHistory.t()
  def record_message_error(history, {:error, message}), do: record_message_error(history, message)

  def record_message_error(history, message) do
    record = WE.HistoryRecord.record_message_error(message)

    history.storage_adapters
    |> Enum.each(fn pr -> pr.store_history_record(record) end)

    update_records(history, record)
  end

  @spec record_task_error(WE.WorkflowHistory.t(), WE.Task.t(), String.t()) ::
          WE.WorkflowHistory.t()
  def record_task_error(history, task, message) do
    record = WE.HistoryRecord.record_task_error(task, message)

    history.storage_adapters
    |> Enum.each(fn pr -> pr.store_history_record(record) end)

    update_records(history, record)
  end

  @spec record_event_error(WE.WorkflowHistory.t(), WE.Event.t(), String.t()) ::
          WE.WorkflowHistory.t()
  def record_event_error(history, event, message) do
    record = WE.HistoryRecord.record_event_error(event, message)

    history.storage_adapters
    |> Enum.each(fn pr -> pr.store_history_record(record) end)

    update_records(history, record)
  end

  defp update_records(history, record) do
    history.storage_adapters
    |> Enum.each(fn pr -> pr.store_history_record(record) end)

    %{history | records: [record | history.records]}
  end
end

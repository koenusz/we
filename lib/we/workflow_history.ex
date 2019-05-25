defmodule WE.WorkflowHistory do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :id, String.t(), default: UUID.uuid1()
    field :workflow_name, String.t()
    field :records, list(WE.HistoryRecord.t()), default: []
    field :storage_providers, [WE.StorageProvider.t()]
  end

  @spec init(String.t(), [WE.StorageProvider.t()]) :: WE.WorkflowHistory.t()
  def init(workflow_name, storage_providers) do
    %WE.WorkflowHistory{workflow_name: workflow_name, storage_providers: storage_providers}
  end

  def recover() do
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
  def record_document(history, %WE.Document{} = doc) do
    record = WE.HistoryRecord.record_document(doc)
    update_records(history, record)
  end

  def find_document do
  end

  def list_documents do
  end

  def record_error(history, error) do
    history.storage_providers
    |> Enum.each(fn pr -> pr.store_error(error) end)
  end

  defp update_records(history, record) do
    history.storage_providers
    |> Enum.each(fn pr -> pr.store_history_record(record) end)

    %{history | records: [record | history.records]}
  end
end

defmodule WE.WorkflowHistory do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :id, String.t(), default: UUID.uuid1()
    field :workflow_name, String.t()
    field :records, list(WE.HistoryRecord.t()), default: []
  end

  @spec init(String.t()) :: WE.WorkflowHistory.t()
  def init(workflow_name) do
    %WE.WorkflowHistory{workflow_name: workflow_name}
  end

  @spec record_task_start(WorkflowHistory.t(), WE.Task.t()) :: WorkflowHistory.t()
  def record_task_start(history, task) do
    record = WE.HistoryRecord.record_task_start(task.name)
    update_records(history, record)
  end

  @spec record_task_complete(WorkflowHistory.t(), WE.Task.t()) :: WorkflowHistory.t()
  def record_task_complete(history, task) do
    record = WE.HistoryRecord.record_task_complete(task.name)
    update_records(history, record)
  end

  @spec record_event(WorkflowHistory.t(), Event.t()) :: WorkflowHistory.t()
  def record_event(history, event) do
    record = WE.HistoryRecord.record_event(event.name)
    update_records(history, record)
  end

  defp update_records(history, record) do
    %{history | records: [record | history.records]}
  end

  def document(_document_id, _operation) do
  end
end

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

  def record_task(history, name, data \\ %{}) do
    record = WE.HistoryRecord.record_task(name, data)
    %{history | records: [record | history.records]}
  end

  def record_event(history, name, data \\ %{}) do
    record = WE.HistoryRecord.record_event(name, data)
    %{history | records: [record | history.records]}
  end
end

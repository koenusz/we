defmodule WE.HistoryRecord do
  use TypedStruct

  @type record_type :: :task_start | :task_complete | :event | :document | :error

  typedstruct enforce: true, opaque: true do
    field :time, DateTime.t(), default: DateTime.utc_now()
    field :step, String.t()
    field :type, record_type()
  end

  @spec record_task_start(WE.Task.t()) :: WE.HistoryRecord.t()
  def record_task_start(task) do
    %WE.HistoryRecord{step: WE.Task.name(task), type: :task_start}
  end

  @spec record_task_complete(WE.Task.t()) :: WE.HistoryRecord.t()
  def record_task_complete(task) do
    %WE.HistoryRecord{step: WE.Task.name(task), type: :task_complete}
  end

  @spec record_event(WE.Event.t()) :: WE.HistoryRecord.t()
  def record_event(event) do
    %WE.HistoryRecord{step: WE.Event.name(event), type: :event}
  end

  @spec record_document(WE.Document.t()) :: WE.HistoryRecord.t()
  def record_document(doc) do
    %WE.HistoryRecord{step: WE.Document.document_id(doc), type: :document}
  end
end

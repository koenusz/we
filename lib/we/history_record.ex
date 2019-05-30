defmodule WE.HistoryRecord do
  use TypedStruct
  @dialyzer {:nowarn_function, record_error: 2}

  @type record_type :: :task_start | :task_complete | :event | :document | :error

  typedstruct enforce: true, opaque: true do
    field :time, DateTime.t(), default: DateTime.utc_now()
    field :id, String.t()
    field :type, record_type()
    field :message, String.t(), enforce: false
  end

  @spec record_task_start(WE.Task.t()) :: WE.HistoryRecord.t()
  def record_task_start(task) do
    %WE.HistoryRecord{id: WE.Task.name(task), type: :task_start}
  end

  @spec record_task_complete(WE.Task.t()) :: WE.HistoryRecord.t()
  def record_task_complete(task) do
    %WE.HistoryRecord{id: WE.Task.name(task), type: :task_complete}
  end

  @spec record_event(WE.Event.t()) :: WE.HistoryRecord.t()
  def record_event(event) do
    %WE.HistoryRecord{id: WE.Event.name(event), type: :event}
  end

  @spec record_document(WE.Document.t()) :: WE.HistoryRecord.t()
  def record_document(doc) do
    %WE.HistoryRecord{id: WE.Document.document_id(doc), type: :document}
  end

  @spec record_error(WE.Task.t(), String.t()) :: WE.HistoryRecord.t()
  def record_error(%WE.Task{} = task, message) do
    %WE.HistoryRecord{id: WE.Task.name(task), message: message, type: :error}
  end

  @spec record_error(WE.Event.t(), String.t()) :: WE.HistoryRecord.t()
  def record_error(%WE.Event{} = event, message) do
    %WE.HistoryRecord{id: WE.Event.name(event), message: message, type: :error}
  end
end

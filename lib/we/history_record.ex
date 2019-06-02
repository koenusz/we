defmodule WE.HistoryRecord do
  use TypedStruct

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

  @spec record_task_error(WE.Task.t(), String.t()) :: WE.HistoryRecord.t()
  def record_task_error(task, message) do
    %WE.HistoryRecord{id: WE.Task.name(task), message: message, type: :error}
  end

  @spec record_event_error(WE.Event.t(), String.t()) :: WE.HistoryRecord.t()
  def record_event_error(event, message) do
    %WE.HistoryRecord{id: WE.Event.name(event), message: message, type: :error}
  end

  @spec record_message_error(String.t()) :: WE.HistoryRecord.t()
  def record_message_error(message) do
    %WE.HistoryRecord{id: UUID.uuid1(), message: message, type: :error}
  end

  def has_document_id?(record, document_id) do
    record.id == document_id and record.type == :document
  end
end

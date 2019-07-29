defmodule WE.HistoryRecord do
  use TypedStruct
  @moduledoc false
  @type record_type :: :task_start | :task_complete | :event | :document | :error

  typedstruct enforce: true, opaque: true do
    field :time, DateTime.t(), default: DateTime.utc_now()
    field :id, String.t()
    field :type, record_type()
    field :message, String.t(), enforce: false
  end

  # constructor
  @spec record_task_start!(WE.State.t()) :: WE.HistoryRecord.t()
  def record_task_start!(task) do
    WE.State.is_task!(task)
    %WE.HistoryRecord{id: WE.State.name(task), type: :task_start}
  end

  @spec record_task_complete!(WE.State.t()) :: WE.HistoryRecord.t()
  def record_task_complete!(task) do
    WE.State.is_task!(task)
    %WE.HistoryRecord{id: WE.State.name(task), type: :task_complete}
  end

  @spec record_event!(WE.State.t()) :: WE.HistoryRecord.t()
  def record_event!(event) do
    WE.State.is_event!(event)
    %WE.HistoryRecord{id: WE.State.name(event), type: :event}
  end

  @spec record_document(WE.Document.t()) :: WE.HistoryRecord.t()
  def record_document(doc) do
    %WE.HistoryRecord{id: WE.Document.name(doc), type: :document}
  end

  @spec record_task_error(WE.State.t(), String.t()) :: WE.HistoryRecord.t()
  def record_task_error(task, message) do
    %WE.HistoryRecord{id: WE.State.name(task), message: message, type: :error}
  end

  @spec record_event_error(WE.State.t(), String.t()) :: WE.HistoryRecord.t()
  def record_event_error(event, message) do
    %WE.HistoryRecord{id: WE.State.name(event), message: message, type: :error}
  end

  @spec record_message_error(String.t()) :: WE.HistoryRecord.t()
  def record_message_error(message) do
    %WE.HistoryRecord{id: WE.Helpers.id(), message: message, type: :error}
  end

  # utils

  @spec is_started_task_with_name?(WE.HistoryRecord.t(), String.t()) :: boolean
  def is_started_task_with_name?(record, task_name) do
    record.type == :task_start and record.id == task_name
  end

  @spec is_completed_task_with_name?(WE.HistoryRecord.t(), String.t()) :: boolean
  def is_completed_task_with_name?(record, task_name) do
    record.type == :task_completed and record.id == task_name
  end

  @spec has_document_id?(WE.HistoryRecord.t(), String.t()) :: boolean
  def has_document_id?(record, document_id) do
    record.id == document_id and record.type == :document
  end
end

defmodule WE.HistoryRecord do
  use TypedStruct

  @type record_type :: :task_start | :task_complete | :event | :document | :error

  typedstruct enforce: true do
    field :time, DateTime.t(), default: DateTime.utc_now()
    field :step, String.t()
    field :type, record_type()
  end

  @spec record_task_start(String.t()) :: WE.HistoryRecord.t()
  def record_task_start(name) do
    %WE.HistoryRecord{step: name, type: :task_start}
  end

  @spec record_task_complete(String.t()) :: WE.HistoryRecord.t()
  def record_task_complete(name) do
    %WE.HistoryRecord{step: name, type: :task_complete}
  end

  @spec record_event(String.t()) :: WE.HistoryRecord.t()
  def record_event(name) do
    %WE.HistoryRecord{step: name, type: :event}
  end
end

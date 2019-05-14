defmodule WE.HistoryRecord do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :time, DateTime.t(), default: DateTime.utc_now()
    field :step, String.t()
    field :data, term
    field :type, atom()
  end

  def record_task(name, data) do
    %WE.HistoryRecord{step: name, data: data, type: :task}
  end

  def record_event(name, data) do
    %WE.HistoryRecord{step: name, data: data, type: :event}
  end
end

defprotocol WE.Step do
  def next(step, data)
end

defimpl WE.Step, for: WE.Task do
  defdelegate next(task, data), to: WE.Task
end

defimpl WE.Step, for: WE.Event do
  defdelegate next(event, data), to: WE.Event
end

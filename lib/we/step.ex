defprotocol WE.Step do
  def next(step)
end

defimpl WE.Step, for: WE.Task do
  defdelegate next(task), to: WE.Task
end

defimpl WE.Step, for: WE.Event do
  defdelegate next(event), to: WE.Event
end

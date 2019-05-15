defmodule WE.Task do
  use TypedStruct

  alias WE.{Task, SequenceFlow, Gateway}

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :sequence_flows, list(SequenceFlow.t()), default: []
    field :command, fun()
    field :gateway, Gateway.gateway(), default: :none
  end

  @spec task(String.t(), fun()) :: WE.Task.t()
  def task(name, command) do
    %Task{name: name, command: command}
  end

  @spec run(WE.Task.t(), any()) :: any()
  def run(task, data) do
    task.command.(data)
  end

  def next(task, data) do
    task.links[0]
  end

  @spec add_sequence_flow(Task.t(), SequenceFlow.t()) :: Task.t()
  def add_sequence_flow(task, sequence_flow) do
    %{task | sequence_flows: [sequence_flow, task.sequence_flows]}
  end
end

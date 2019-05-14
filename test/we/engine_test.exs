defmodule WE.EngineTest do
  use ExUnit.Case

  alias WE.{Workflow, Event, Task, Engine, SequenceFlow}

  test "start stop" do
    link = SequenceFlow.default("start", "stop")

    start = Event.start_event("start", [link])
    stop = Event.end_event("stop")
    workflow = Workflow.workflow("test1", [start, stop])
    :ok = Workflow.validate(workflow)

    {:ok, engine} = Engine.start_link(workflow)

    state =
      engine
      |> Engine.start()
      |> IO.inspect()

    assert length(state.records) == 2
  end
end

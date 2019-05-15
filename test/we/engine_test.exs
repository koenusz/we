defmodule WE.EngineTest do
  use ExUnit.Case

  alias WE.{Workflow, Event, Task, Engine, SequenceFlow, TestWorkflowHelper}

  test "start stop" do
    workflow =
      TestWorkflowHelper.start_stop()
      |> IO.inspect()

    {:ok, engine} = Engine.start_link(workflow)

    state =
      engine
      |> Engine.start()
      |> IO.inspect()

    assert length(state.records) == 2
  end

  test "task" do
    workflow = TestWorkflowHelper.task()

    {:ok, engine} = Engine.start_link(workflow)

    state =
      engine
      |> Engine.start()
      |> IO.inspect()

    assert length(state.records) == 2
  end
end

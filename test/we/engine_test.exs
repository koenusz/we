defmodule WE.EngineTest do
  use ExUnit.Case

  alias WE.{Workflow, Task, Engine, TestWorkflowHelper}

  test "start stop" do
    workflow = TestWorkflowHelper.start_stop()

    {:ok, engine} = Engine.start_link(workflow)

    state =
      engine
      |> Engine.start_execution()

    assert length(state.records) == 2
  end

  test "complete task with default flow" do
    workflow = TestWorkflowHelper.task()
    task = Workflow.get_step_by_name(workflow, "task")
    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    Engine.start_task(engine, task)

    Engine.history(engine)

    Engine.complete_task(engine, task)

    Engine.current_state(engine)

    history = Engine.history(engine)

    assert length(history.records) == 4
  end

  test "complete task with designated flow" do
    workflow = TestWorkflowHelper.task()
    task = Workflow.get_step_by_name(workflow, "task")
    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    Engine.start_task(engine, task)

    Engine.complete_task(engine, task, Task.flow_to(task, ["stop"]))

    history = Engine.history(engine)
    assert length(history.records) == 4
  end
end

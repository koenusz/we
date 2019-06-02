defmodule WE.EngineTest do
  use ExUnit.Case, async: true

  alias WE.{Workflow, Task, Engine, TestWorkflowHelper}

  test "start stop" do
    workflow = TestWorkflowHelper.start_stop()

    {:ok, engine} = Engine.start_link(workflow)

    :ok =
      engine
      |> Engine.start_execution()

    {:ok, history} = Engine.history(engine)
    assert length(history.records) == 2
  end

  test "complete task with default flow" do
    workflow = TestWorkflowHelper.task()
    task = Workflow.get_step_by_name(workflow, "task")
    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    Engine.start_task(engine, task)
    assert {:ok, [task]} == Engine.current_state(engine)

    Engine.complete_task(engine, task)
    {:ok, history} = Engine.history(engine)
    assert length(history.records) == 4
    Engine.start_task(engine, task)

    assert {:ok, [%WE.Event{name: "stop", sequence_flows: [], type: :end}]} ==
             Engine.current_state(engine)
  end

  test "complete task with designated flow" do
    workflow = TestWorkflowHelper.task()
    task = Workflow.get_step_by_name(workflow, "task")
    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    :ok = Engine.start_task(engine, task)
    task = Task.start_task(task)
    assert {:ok, [task]} == Engine.current_state(engine)

    Engine.start_task(engine, task)
    :ok = Engine.complete_task(engine, task, Task.flow_to(task, ["stop"]))

    {:ok, history} = Engine.history(engine)

    assert length(history.records) == 4
    Engine.start_task(engine, task)

    assert {:ok, [%WE.Event{name: "stop", sequence_flows: [], type: :end}]} ==
             Engine.current_state(engine)
  end

  test "received event, error not in current state" do
  end

  test "received task, error not in current state" do
  end
end

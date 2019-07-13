defmodule WE.EngineTest do
  use ExUnit.Case, async: true

  alias WE.{Workflow, Engine, TestWorkflowHelper}

  test "start stop" do
    workflow = TestWorkflowHelper.start_stop()

    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    {:ok, _pid, history} = Engine.history(engine)
    assert length(history.records) == 2
  end

  test "complete task with default flow" do
    workflow = TestWorkflowHelper.service_task()
    {:ok, task} = Workflow.get_step_by_name(workflow, "task")
    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    Engine.start_task(engine, task)
    {:ok, _pid, task_list} = Engine.current_state(engine)

    assert [task] == task_list

    Engine.complete_task(engine, task)
    {:ok, _pid, history} = Engine.history(engine)
    assert length(history.records) == 4
    Engine.start_task(engine, task)

    {:ok, _pid, task_list} = Engine.current_state(engine)

    assert [WE.State.end_event("stop")] == task_list
  end

  test "complete task with designated flow" do
    workflow = TestWorkflowHelper.service_task()
    {:ok, task} = Workflow.get_step_by_name(workflow, "task")
    {:ok, engine} = Engine.start_link(workflow)

    engine
    |> Engine.start_execution()

    Engine.start_task(engine, task)
    task = WE.State.start_task(task)
    {:ok, _pid, task_list} = Engine.current_state(engine)

    assert [task] == task_list

    Engine.start_task(engine, task)
    Engine.complete_task(engine, task, WE.State.flow_to(task, ["stop"]))

    {:ok, _pid, history} = Engine.history(engine)

    assert length(history.records) == 4
    Engine.start_task(engine, task)

    assert {:ok, [%WE.State{name: "stop", type: :end}]} ==
             Engine.current_state(engine)
  end

  test "received event, error not in current state" do
  end

  test "received task, error not in current state" do
  end
end

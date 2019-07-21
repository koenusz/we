defmodule WE.EngineTest do
  use ExUnit.Case, async: true

  alias WE.{Workflow, Engine, TestWorkflowHelper}

  @business_id "test business id"

  @storage_adapters [WE.Adapter.Local]

  describe "test supervision tree" do
    test "when an engine stops the document library should stop too" do
      # currently when it crashes it creates a new one, maybe we can reattach it??
    end

    test "when the document library crashes the engine should stay alive" do
    end

    test "when an engine is restarted the current state and document library should be revived from the storage provider" do
    end
  end

  test "start stop" do
    workflow = TestWorkflowHelper.start_stop()

    {:ok, _engine} = Engine.start_link(@storage_adapters, @business_id, workflow)

    @business_id
    |> Engine.start_execution()

    {:ok, _pid, history} = Engine.history(@business_id)
    assert length(history.records) == 2
  end

  test "complete task with default flow" do
    workflow = TestWorkflowHelper.service_task()
    {:ok, task} = Workflow.get_step_by_name(workflow, "task")
    {:ok, _engine} = Engine.start_link(@storage_adapters, @business_id, workflow)

    @business_id
    |> Engine.start_execution()

    Engine.start_task(@business_id, task)
    {:ok, _pid, task_list} = Engine.current_state(@business_id)

    assert [task] == task_list

    Engine.complete_task(@business_id, task)
    {:ok, _pid, history} = Engine.history(@business_id)
    assert length(history.records) == 4
    Engine.start_task(@business_id, task)

    {:ok, _pid, task_list} = Engine.current_state(@business_id)

    assert [WE.State.end_event("stop")] == task_list
  end

  test "complete task with designated flow" do
    workflow = TestWorkflowHelper.service_task()
    {:ok, task} = Workflow.get_step_by_name(workflow, "task")
    {:ok, _engine} = Engine.start_link(@storage_adapters, @business_id, workflow)

    @business_id
    |> Engine.start_execution()

    {:ok, _pid, task_list} = Engine.current_state(@business_id)
    assert [task] == task_list

    Engine.start_task(@business_id, task)

    assert Engine.history(@business_id)
           |> WE.Helpers.unpack_engine_tuple_value()
           |> WE.WorkflowHistory.task_started?(WE.State.name(task))

    Engine.complete_task(@business_id, task, [WE.SequenceFlow.sequence_flow("task", "stop")])

    {:ok, _pid, history} = Engine.history(@business_id)

    assert length(history.records) == 4
    Engine.start_task(@business_id, task)

    assert {:ok, @business_id, [WE.State.end_event("stop")]} ==
             Engine.current_state(@business_id)
  end

  test "received event, error not in current state" do
  end

  test "received task, error not in current state" do
  end
end

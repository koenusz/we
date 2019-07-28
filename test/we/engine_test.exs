defmodule WE.EngineTest do
  use ExUnit.Case, async: true

  alias WE.{Workflow, Engine, TestWorkflowHelper}

  @storage_adapters [WE.Adapter.Local]

  test "start stop" do
    workflow = TestWorkflowHelper.start_stop()

    business_id = WE.Helpers.id()

    {:ok, _engine} = Engine.start_link(@storage_adapters, [business_id, workflow])

    business_id
    |> Engine.start_execution()

    {:ok, _pid, history} = Engine.history(business_id)
    assert length(history.records) == 2
  end

  test "complete task with default flow" do
    business_id = WE.Helpers.id()
    workflow = TestWorkflowHelper.service_task()
    {:ok, task} = Workflow.get_step_by_name(workflow, "task")
    {:ok, _engine} = Engine.start_link(@storage_adapters, [business_id, workflow])

    business_id
    |> Engine.start_execution()

    Engine.start_task(business_id, task)
    {:ok, _pid, task_list} = Engine.current_state(business_id)

    assert [task] == task_list

    Engine.complete_task(business_id, task)
    {:ok, _pid, history} = Engine.history(business_id)
    assert length(history.records) == 4
    Engine.start_task(business_id, task)

    {:ok, _pid, task_list} = Engine.current_state(business_id)

    assert [WE.State.end_event("stop")] == task_list
  end

  test "complete task with designated flow" do
    business_id = WE.Helpers.id()
    workflow = TestWorkflowHelper.service_task()
    {:ok, task} = Workflow.get_step_by_name(workflow, "task")
    {:ok, _engine} = Engine.start_link(@storage_adapters, business_id, workflow)

    business_id
    |> Engine.start_execution()

    {:ok, _pid, task_list} = Engine.current_state(business_id)
    assert [task] == task_list

    Engine.start_task(business_id, task)

    assert Engine.history(business_id)
           |> WE.Helpers.unpack_engine_tuple_value()
           |> WE.WorkflowHistory.task_started?(WE.State.name(task))

    Engine.complete_task(business_id, task, [WE.SequenceFlow.sequence_flow("task", "stop")])

    {:ok, _pid, history} = Engine.history(business_id)

    assert length(history.records) == 4
    Engine.start_task(business_id, task)

    assert {:ok, business_id, [WE.State.end_event("stop")]} ==
             Engine.current_state(business_id)
  end

  test "received event, error not in current state" do
    business_id = WE.Helpers.id()
    workflow = WE.TestWorkflowHelper.message_split()
    init_and_start_engine(business_id, workflow)
    {:ok, task} = Workflow.get_step_by_name(workflow, "message2")

    Engine.start_task(business_id, "message2")

    {:ok, _pid, history} = Engine.history(business_id)

    assert Enum.member?(
             history.records,
             WE.HistoryRecord.record_task_error(task, "task message2 not in current state")
           )
  end

  test "received task, error not in current state" do
    business_id = WE.Helpers.id()
    workflow = WE.TestWorkflowHelper.task_event()
    init_and_start_engine(business_id, workflow)
    {:ok, event} = Workflow.get_step_by_name(workflow, "event")

    Engine.message_event(business_id, "event")

    {:ok, _pid, history} = Engine.history(business_id)

    assert Enum.member?(
             history.records,
             WE.HistoryRecord.record_event_error(
               event,
               "event not in current state"
             )
           )
  end

  defp init_and_start_engine(business_id, workflow) do
    {:ok, _engine} = Engine.start_link(@storage_adapters, [business_id, workflow])

    business_id
    |> Engine.start_execution()
  end
end

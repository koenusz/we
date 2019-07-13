defmodule WE.TestWorkflowHelper do
  alias WE.{SequenceFlow, Workflow}

  def start_stop() do
    Workflow.workflow("start stop test")
    |> Workflow.add_start_event("start")
    |> Workflow.add_end_event("stop")
    |> Workflow.add_default_sequence_flow("start", "stop")
  end

  def message do
    Workflow.workflow("message test")
    |> Workflow.add_start_event("start")
    |> Workflow.add_message_event("message")
    |> Workflow.add_end_event("stop")
    |> Workflow.add_default_sequence_flow("start", "message")
    |> Workflow.add_default_sequence_flow("message", "stop")
  end

  def message_split do
    Workflow.workflow("message split test")
    |> Workflow.add_start_event("start")
    |> Workflow.add_message_event("message1")
    |> Workflow.add_message_event("message2")
    |> Workflow.add_end_event("stop")
    |> Workflow.add_default_sequence_flow("start", "message1")
    |> Workflow.add_sequence_flow("start", "message2")
    |> Workflow.add_default_sequence_flow("message1", "stop")
    |> Workflow.add_default_sequence_flow("message2", "stop")
  end

  def service_task do
    Workflow.workflow("service task test")
    |> Workflow.add_start_event("start")
    |> Workflow.add_service_task("task")
    |> Workflow.add_end_event("stop")
    |> Workflow.add_default_sequence_flow("start", "task")
    |> Workflow.add_default_sequence_flow("task", "stop")
  end
end

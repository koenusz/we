defmodule WE.TestWorkflowHelper do
  alias WE.{SequenceFlow, Workflow}

  def start_stop() do
    flow = SequenceFlow.default("start", "stop")

    start =
      WE.State.start_event("start")
      |> WE.State.add_sequence_flow(flow)

    stop = WE.State.end_event("stop")
    workflow = Workflow.workflow("test1", [start, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end

  def message do
    start =
      WE.State.start_event("start")
      |> WE.State.add_sequence_flow(SequenceFlow.default("start", "message"))

    message =
      WE.State.message_event("message")
      |> WE.State.add_sequence_flow(SequenceFlow.default("message", "stop"))

    stop = WE.State.end_event("stop")
    workflow = Workflow.workflow("wf1", [start, message, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end

  def message_split do
    start =
      WE.State.start_event("start")
      |> WE.State.add_sequence_flow(SequenceFlow.default("start", "message1"))
      |> WE.State.add_sequence_flow(SequenceFlow.no_default("start", "message2"))

    message1 =
      WE.State.message_event("message1")
      |> WE.State.add_sequence_flow(SequenceFlow.default("message1", "stop"))

    message2 =
      WE.State.message_event("message2")
      |> WE.State.add_sequence_flow(SequenceFlow.default("message2", "stop"))

    stop = WE.State.end_event("stop")
    workflow = Workflow.workflow("wf1", [start, message1, message2, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end

  def task do
    start =
      WE.State.start_event("start")
      |> WE.State.add_sequence_flow(SequenceFlow.default("start", "task"))

    task =
      WE.State.service_task("task")
      |> WE.State.add_sequence_flow(SequenceFlow.default("task", "stop"))

    stop = WE.State.end_event("stop")
    workflow = Workflow.workflow("wf1", [start, task, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end
end

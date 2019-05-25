defmodule WE.TestWorkflowHelper do
  alias WE.{Event, SequenceFlow, Workflow, Task}

  def start_stop() do
    flow = SequenceFlow.default("start", "stop")

    start =
      Event.start_event("start", [])
      |> Event.add_sequence_flow(flow)

    stop = Event.end_event("stop")
    workflow = Workflow.workflow("test1", [start, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end

  def message do
    start =
      Event.start_event("start", [])
      |> Event.add_sequence_flow(SequenceFlow.default("start", "message"))

    message =
      Event.message_event("message", [])
      |> Event.add_sequence_flow(SequenceFlow.default("message", "stop"))

    stop = Event.end_event("stop")
    workflow = Workflow.workflow("wf1", [start, message, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end

  def message_split do
    start =
      Event.start_event("start", [])
      |> Event.add_sequence_flow(SequenceFlow.default("start", "message1"))
      |> Event.add_sequence_flow(SequenceFlow.no_default("start", "message2"))

    message1 =
      Event.message_event("message1", [])
      |> Event.add_sequence_flow(SequenceFlow.default("message1", "stop"))

    message2 =
      Event.message_event("message2", [])
      |> Event.add_sequence_flow(SequenceFlow.default("message2", "stop"))

    stop = Event.end_event("stop")
    workflow = Workflow.workflow("wf1", [start, message1, message2, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end

  def task do
    start =
      Event.start_event("start", [])
      |> Event.add_sequence_flow(SequenceFlow.default("start", "task"))

    task =
      Task.task("task", [])
      |> Task.add_sequence_flow(SequenceFlow.default("task", "stop"))

    stop = Event.end_event("stop")
    workflow = Workflow.workflow("wf1", [start, task, stop])
    :ok = WE.WorkflowValidator.validate(workflow)
    workflow
  end
end

defmodule WE.DocumentTest do
  use ExUnit.Case, async: true

  describe "definition phase" do
    test "add a document to a workflow" do
      required = WE.Document.document(%{data: "bla"})

      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(required)

      documents = WE.Workflow.get_documents(workflow)

      assert documents == [required.id, []]
    end

    test "add a document to a step in a workflow" do
      required = WE.Document.document(%{data: "bla"})

      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(required, "start")

      documents = WE.Workflow.get_documents(workflow)

      assert documents == [{required.id, "start"}, []]
    end
  end

  describe "execution phase" do
    test "complete a task with an optional document" do
      document = WE.Document.optional_document(%{data: "optional"})

      workflow =
        WE.TestWorkflowHelper.task()
        |> WE.Workflow.add_document(document, "task")

      current_state =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop")]
    end

    test "complete a task with a required document" do
      document = WE.Document.document(%{data: "required"})

      workflow =
        WE.TestWorkflowHelper.task()
        |> WE.Workflow.add_document(document, "task")

      current_state =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop")]
    end

    test "complete a task with the optional document missing" do
      document = WE.Document.optional_document(%{data: "optional"})

      workflow =
        WE.TestWorkflowHelper.task()
        |> WE.Workflow.add_document(document, "task")

      current_state =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop")]
    end

    test "complete a task with a required document missing" do
      document = WE.Document.document(%{data: "required"})

      workflow =
        WE.TestWorkflowHelper.task()
        |> WE.Workflow.add_document(document, "task")

      current_state =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "task")]
    end

    test "find document by stage" do
      assert false
    end

    test "list complete/incomplete documents for the workflow" do
      assert false
    end

    test "check if a workflow has all required documents" do
      assert false
    end
  end
end

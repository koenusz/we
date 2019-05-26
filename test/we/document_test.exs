defmodule WE.DocumentTest do
  use ExUnit.Case, async: true

  setup thedoc do
    WE.Document.document(%{data: "bla"})
    :ok
  end

  describe "definition phase" do
    test "add a document to a workflow", thedoc do
      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(thedoc)

      documents = WE.Workflow.get_documents(workflow)

      assert documents == [thedoc.id, []]
    end

    test "add a document to a step in a workflow", thedoc do
      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(thedoc, "start")

      documents = WE.Workflow.get_documents(workflow)

      assert documents == [{thedoc.id, "start"}, []]
    end
  end

  describe "execution phase" do
    test "complete a task with an optional document", thedoc do
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

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop")]
    end

    test "complete a task with a required document" do
      assert false
    end

    test "complete a task with a required document and the optional document missing" do
      assert false
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

defmodule WE.DocumentTest do
  use ExUnit.Case, async: true

  describe "definition phase" do
    test "add a document to a workflow" do
      thedoc = WE.Document.document(%{data: "bla"})

      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(thedoc)

      documents = WE.Workflow.get_documents(workflow)

      assert documents == [thedoc.id, []]
    end

    test "add a document to a s step in a workflow" do
      thedoc = WE.Document.document(%{data: "bla"})

      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(thedoc, "start")

      documents = WE.Workflow.get_documents(workflow)

      assert documents == [{thedoc.id, "start"}, []]
    end
  end

  describe "execution phase" do
    test "complete a task with an optional document" do
      assert false
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

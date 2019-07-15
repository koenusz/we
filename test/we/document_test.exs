defmodule WE.DocumentTest do
  use ExUnit.Case, async: true

  @history_id "123"

  setup_all do
    wf = WE.TestWorkflowHelper.start_stop()
    WE.DocumentSupervisor.add_library("123", wf, [WE.Adapter.Local])
    :ok
  end

  describe "registry" do
    setup do
      wf = WE.TestWorkflowHelper.start_stop()
      doc = WE.Document.document(%{})
      [wf: wf, doc: doc]
    end

    test "add library", wf do
      {:ok, pid} = WE.DocumentSupervisor.add_library("1234", wf, [])
      assert is_pid(pid)
    end

    test "add library same id", wf do
      {:error, {:already_started, pid}} = WE.DocumentSupervisor.add_library("123", wf, [])
      assert is_pid(pid)
    end

    test "store and find a document in the library", ctx do
      WE.DocumentLibrary.store_document(@history_id, ctx.doc)

      assert ctx.doc ==
               WE.DocumentLibrary.get_document(@history_id, WE.Document.name(ctx.doc))
               |> elem(1)
    end

    test "find with empty library" do
      assert [error: "not found"] ==
               WE.DocumentLibrary.all_documents_in(@history_id, ["not present"])
               |> elem(1)
    end

    test "find library", ctx do
      WE.DocumentLibrary.store_document(@history_id, ctx.doc)

      assert [ctx.doc] ==
               WE.DocumentLibrary.all_documents_in(@history_id, [WE.Document.name(ctx.doc)])
               |> elem(1)
    end
  end

  describe "definition phase" do
    test "add a document to a workflow" do
      required = WE.Document.document("required")

      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(required)

      documents = WE.Workflow.get_document_references(workflow)

      assert documents == [
               %WE.DocumentReference{
                 name: WE.Document.name(required),
                 step_name: "",
                 type: :required
               }
             ]
    end

    test "add a document to a step in a workflow" do
      required = WE.Document.document(%{data: "bla"})

      workflow =
        WE.TestWorkflowHelper.start_stop()
        |> WE.Workflow.add_document(required, "start")

      documents = WE.Workflow.get_document_references(workflow)

      assert documents == [
               %WE.DocumentReference{
                 name: WE.Document.name(required),
                 step_name: "start",
                 type: :required
               }
             ]
    end
  end

  describe "execution phase" do
    test "complete a task with an optional document" do
      document = WE.Document.optional_document("optional")

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      current_state =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop") |> elem(1)]
    end

    test "complete a task with the optional document missing" do
      document = WE.Document.optional_document("optional")

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      current_state =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop") |> elem(1)]
    end

    test "complete a task with a required document" do
      document = WE.Document.document("required")

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      engine =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()

      history_id =
        WE.Engine.history(engine)
        |> elem(2)
        |> WE.WorkflowHistory.id()

      WE.DocumentLibrary.store_document(history_id, document)

      {:ok, engine, current_state} =
        engine
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()

      # |> elem(2)

      WE.Engine.history(engine)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop") |> elem(1)]
    end

    test "complete a task with a required document missing" do
      document = WE.Document.document(%{data: "required"})

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      {:ok, engine, current_state} =
        WE.Engine.start_link(workflow)
        |> elem(1)
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()

      WE.Engine.history(engine)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "task") |> elem(1)]
    end

    # test "find document by stage" do
    #   assert false
    # end

    # test "list complete/incomplete documents for the workflow" do
    #   assert false
    # end

    # test "check if a workflow has all required documents" do
    #   assert false
    # end
  end
end

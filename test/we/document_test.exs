defmodule WE.DocumentTest do
  use ExUnit.Case, async: true

  @storage_adapters [WE.Adapter.Local]

  describe "registry" do
    setup do
      wf = WE.TestWorkflowHelper.start_stop()
      doc = WE.Document.document("setup")
      history_id = WE.Helpers.id()
      WE.DocumentSupervisor.add_library(history_id, wf, [WE.Adapter.Local])
      %{wf: wf, doc: doc, history_id: history_id}
    end

    test "add library", wf do
      {:ok, pid} = WE.DocumentSupervisor.add_library("1234", wf, [])
      assert is_pid(pid)
    end

    test "add library same id", %{wf: wf, history_id: history_id} do
      {:error, {:already_started, pid}} = WE.DocumentSupervisor.add_library(history_id, wf, [])
      assert is_pid(pid)
    end

    test "store and find a document in the library", %{history_id: history_id, doc: doc} do
      WE.DocumentLibrary.store_document(history_id, doc)

      assert doc ==
               WE.DocumentLibrary.get_document(history_id, WE.Document.name(doc))
               |> elem(1)
    end

    test "find with empty library", %{history_id: history_id} do
      assert [error: "not found"] ==
               WE.DocumentLibrary.all_documents_in(history_id, ["not present"])
               |> elem(1)
    end

    test "find library", %{history_id: history_id, doc: doc} do
      WE.DocumentLibrary.store_document(history_id, doc)

      assert [doc] ==
               WE.DocumentLibrary.all_documents_in(history_id, [WE.Document.name(doc)])
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
      business_id = WE.Helpers.id()

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      {:ok, _pid} = WE.Engine.start_link(@storage_adapters, [business_id, workflow])

      current_state =
        business_id
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop") |> elem(1)]
    end

    test "complete a task with the optional document missing" do
      document = WE.Document.optional_document("optional")
      business_id = WE.Helpers.id()

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      {:ok, _pid} = WE.Engine.start_link(@storage_adapters, [business_id, workflow])

      current_state =
        business_id
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()
        |> elem(2)

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop") |> elem(1)]
    end

    test "complete a task with a required document" do
      document = WE.Document.document("required")
      business_id = WE.Helpers.id()

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      {:ok, _pid} = WE.Engine.start_link(@storage_adapters, [business_id, workflow])

      business_id
      |> WE.Engine.start_execution()
      |> WE.Engine.history()

      WE.DocumentLibrary.store_document(business_id, document)

      {:ok, _, current_state} =
        business_id
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "stop") |> elem(1)]
    end

    test "complete a task with a required document missing" do
      document = WE.Document.document("required")
      business_id = WE.Helpers.id()

      workflow =
        WE.TestWorkflowHelper.service_task()
        |> WE.Workflow.add_document(document, "task")

      {:ok, _pid} = WE.Engine.start_link(@storage_adapters, [business_id, workflow])

      {:ok, _, current_state} =
        business_id
        |> WE.Engine.start_execution()
        |> WE.Engine.start_task("task")
        |> WE.Engine.complete_task("task")
        |> WE.Engine.current_state()

      assert current_state == [WE.Workflow.get_step_by_name(workflow, "task") |> elem(1)]
    end
  end
end

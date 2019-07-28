defmodule WE.SupervisorTest do
  use ExUnit.Case, async: true

  @business_id "my_id"
  @document_name "the doc"

  setup do
    required = WE.Document.document(@document_name)

    workflow =
      WE.TestWorkflowHelper.task_event()
      |> WE.Workflow.add_document(required, "task")

    WE.init_engine(@business_id, workflow)
    WE.start_engine(@business_id)
    WE.start_task(@business_id, "task")
    WE.store_document(@business_id, @document_name, %{my_data: "bla"})
    history = WE.Engine.history(@business_id)

    [doc: required, workflow: workflow, history_id: WE.WorkflowHistory.id(history)]
  end

  test "the engine crashes", history_id do
    count = WE.EngineSupervisor.count_children()

    {:ok, engine} = Registry.lookup(:engine_registry, @business_id)
    {:ok, library} = Registry.lookup(:document_registry, history_id)

    assert Process.exit(engine, :kill)

    :timer.sleep(100)

    assert count == WE.EngineSupervisor.count_children()
    {:ok, after_engine} = Registry.lookup(:engine_registry, @business_id)
    {:ok, after_library} = Registry.lookup(:document_registry, history_id)

    assert engine != after_engine
    assert library == after_library
  end

  test "the codumentlibrary crashes", history_id do
    count = WE.EngineSupervisor.count_children()

    {:ok, engine} = Registry.lookup(:engine_registry, @business_id)
    {:ok, library} = Registry.lookup(:document_registry, history_id)

    assert Process.exit(library, :kill)

    :timer.sleep(100)

    assert count == WE.EngineSupervisor.count_children()
    {:ok, after_engine} = Registry.lookup(:engine_registry, @business_id)
    {:ok, after_library} = Registry.lookup(:document_registry, history_id)

    assert engine == after_engine
    assert library != after_library
  end
end

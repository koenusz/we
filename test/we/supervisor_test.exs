defmodule WE.SupervisorTest do
  use ExUnit.Case, async: true

  @document_name "the doc"

  setup do
    required = WE.Document.document(@document_name)
    business_id = WE.Helpers.id()

    workflow =
      WE.TestWorkflowHelper.task_event()
      |> WE.Workflow.add_document(required, "task")

    IO.puts("------")

    {:ok, pid} = WE.init_engine(business_id, workflow)

    WE.start_engine(business_id)
    WE.start_task(business_id, "task")
    WE.store_document(business_id, @document_name, %{my_data: "bla"})

    %{business_id: business_id}
  end

  test "the engine crashes", %{business_id: business_id} do
    count = WE.EngineSupervisor.count_children()

    [{engine, nil}] = Registry.lookup(:engine_registry, business_id)
    [{library, nil}] = Registry.lookup(:document_registry, business_id)

    assert Process.exit(engine, :kill)

    :timer.sleep(100)

    assert count == WE.EngineSupervisor.count_children()
    [{after_engine, nil}] = Registry.lookup(:engine_registry, business_id)
    [{after_library, nil}] = Registry.lookup(:document_registry, business_id)

    assert engine != after_engine
    assert library == after_library
  end

  test "the codumentlibrary crashes", %{business_id: business_id} do
    count = WE.EngineSupervisor.count_children()

    [{engine, nil}] = Registry.lookup(:engine_registry, business_id)
    [{library, nil}] = Registry.lookup(:document_registry, business_id)

    assert Process.exit(library, :kill)

    :timer.sleep(100)

    assert count == WE.EngineSupervisor.count_children()
    [{after_engine, nil}] = Registry.lookup(:engine_registry, business_id)
    [{after_library, nil}] = Registry.lookup(:document_registry, business_id)

    assert engine == after_engine
    assert library != after_library
  end
end

defmodule WE.DocumentLibrary do
  use GenServer
  use TypedStruct

  @impl GenServer
  @spec init({WE.Workflow.t(), [module()]}, any()) ::
          {:ok, {WE.Workflow.t(), list(WE.Document.t()), list(module())}}
  def init({workflow, storage_providers}, _opts \\ []) do
    {:ok, {workflow, [], storage_providers}}
  end

  @impl GenServer
  def handle_call({:store, document}, _from, {workflow, documents, storage_providers}) do
    storage_providers
    |> Enum.each(fn pr -> pr.store_document(document) end)

    {:reply, :ok, {workflow, [document, documents], storage_providers}}
  end

  @impl GenServer
  def handle_call({:update, document}, _from, {workflow, documents, storage_providers}) do
    storage_providers
    |> Enum.each(fn pr -> pr.update_document(document) end)

    documents =
      documents
      |> Enum.filter(fn doc ->
        not WE.Document.same_id?(doc, document)
      end)

    {:reply, :ok, {workflow, [document, documents], storage_providers}}
  end

  # client
  @spec store_document(pid, WE.Document.t()) :: {:ok, any()}
  def store_document(library, document) do
    GenServer.call(library, {:store, document})
  end

  @spec update_document(pid, WE.Document.t()) :: {:ok, any()}
  def update_document(library, document) do
    GenServer.call(library, {:update, document})
  end
end

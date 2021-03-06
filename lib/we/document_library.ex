defmodule WE.DocumentLibrary do
  use GenServer
  use TypedStruct
  @moduledoc false
  @document_registry_name :document_registry

  # client
  @spec store_document(String.t(), WE.Document.t()) :: {:ok, any()}
  def store_document(history_id, document) do
    GenServer.call(via_tuple(history_id), {:store, document})
  end

  @spec update_document(String.t(), WE.Document.t()) :: {:ok, any()}
  def update_document(history_id, document) do
    GenServer.call(via_tuple(history_id), {:update, document})
  end

  @spec get_document(String.t(), String.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  def get_document(history_id, document_id) do
    GenServer.call(via_tuple(history_id), {:get, document_id})
  end

  @spec all_documents(String.t()) :: {:ok, [WE.Document.t()]}
  def all_documents(history_id) do
    GenServer.call(via_tuple(history_id), {:get_all})
  end

  @spec all_documents_in(String.t(), [String.t()]) :: {:ok, [WE.Document.t()]}
  def all_documents_in(history_id, document_ids) do
    GenServer.call(via_tuple(history_id), {:get_all_in, document_ids})
  end

  @spec all_required_documents_present?(String.t(), String.t()) :: boolean
  def all_required_documents_present?(history_id, step_name) do
    GenServer.call(via_tuple(history_id), {:all_required_present, step_name})
  end

  @spec start_link({WE.WorkflowHistory.t(), WE.Workflow.t(), [atom]}) ::
          :ignore | {:error, any} | {:ok, pid}
  def start_link({history_id, workflow, storage_adapters}) do
    GenServer.start_link(__MODULE__, {history_id, workflow, storage_adapters},
      name: via_tuple(history_id)
    )
  end

  # registry lookup handler
  defp via_tuple(history_id), do: {:via, Registry, {@document_registry_name, history_id}}

  @impl GenServer
  @spec init({String.t(), WE.Workflow.t(), [module()]}, any()) ::
          {:ok, {String.t(), WE.Workflow.t(), list(WE.Document.t()), list(module())}}
  def init({history_id, workflow, storage_adapters}, _opts \\ []) do
    {:ok, {history_id, workflow, [], storage_adapters}}
  end

  @impl GenServer
  def handle_call(
        {:all_required_present, step_name},
        _from,
        {history_id, workflow, documents, storage_adapters}
      ) do
    present_doc_ids =
      documents
      |> Enum.map(&WE.Document.name(&1))

    required_doc_ids = WE.Workflow.all_required_document_ids_for_step(workflow, step_name)

    required_and_complete =
      all_required_present?(present_doc_ids, required_doc_ids) and
        all_documents_complete?(documents)

    {:reply, required_and_complete, {history_id, workflow, documents, storage_adapters}}
  end

  @impl GenServer
  def handle_call({:store, document}, _from, {history_id, workflow, documents, storage_adapters}) do
    storage_adapters
    |> Enum.each(fn pr -> pr.store_document(document) end)

    {:reply, :ok, {history_id, workflow, [document | documents], storage_adapters}}
  end

  # todo perhaps we need a better strategy to get a document other than to just get the top adapter
  @impl GenServer
  def handle_call(
        {:get, document_id},
        _from,
        {history_id, workflow, documents, storage_adapters}
      ) do
    response =
      case storage_adapters do
        [] -> {:error, "no storage providers"}
        [h | _t] -> h.find_document(document_id)
      end

    {:reply, response, {history_id, workflow, documents, storage_adapters}}
  end

  @impl GenServer
  def handle_call(
        {:get_all},
        _from,
        {history_id, workflow, documents, storage_adapters}
      ) do
    {:reply, documents, {history_id, workflow, documents, storage_adapters}}
  end

  @impl GenServer
  def handle_call(
        {:get_all_in, document_ids},
        _from,
        {history_id, workflow, documents, storage_adapters}
      ) do
    response = get_all_in(storage_adapters, document_ids)
    {:reply, response, {history_id, workflow, documents, storage_adapters}}
  end

  @impl GenServer
  def handle_call(
        {:update, document},
        _from,
        {history_id, workflow, documents, storage_adapters}
      ) do
    storage_adapters
    |> Enum.each(fn pr -> pr.update_document(document) end)

    documents =
      documents
      |> Enum.filter(&WE.Document.same_name?(&1, document))

    {:reply, :ok, {history_id, workflow, [document, documents], storage_adapters}}
  end

  defp get_all_in(storage_adapters, document_ids) do
    case storage_adapters do
      [] ->
        {:error, "no storage providers"}

      [h | _t] ->
        {:ok,
         document_ids |> Enum.map(fn document_id -> h.find_document(document_id) |> elem(1) end)}
    end
  end

  defp all_documents_complete?(present_docs) do
    present_docs
    |> Enum.all?(&WE.Document.is_complete?(&1))
  end

  defp all_required_present?(present_docs_ids, required_docs_ids) do
    [] == required_docs_ids -- present_docs_ids
  end
end

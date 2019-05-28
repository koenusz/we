defmodule WE.InMemoryStorage do
  @moduledoc ~S"""
  In-memory storage used by the
  [WE.Adapter.Local](WE.Adapter.Local.html) module.
  The data in this storage is stored in memory and won't persist once your
  application is stopped.
  """
  use GenServer

  @doc """
  Starts the InMemoryStorage server
  """
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Stops the InMemoryStorage server
  """
  def stop() do
    GenServer.stop(__MODULE__)
  end

  # callbacks
  @impl GenServer
  def init(_args) do
    {:ok, %{documents: [], history_records: %{}}}
  end

  @impl GenServer
  def handle_call({:store_document, document}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    {:reply, document, %{documents: [document | documents], history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:update_document, document}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    documents =
      documents
      |> Enum.filter(fn doc ->
        not WE.Document.same_id?(doc, document)
      end)

    {:reply, document, %{documents: [document | documents], history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:find_document, document_id}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    found = WE.Document.find(documents, document_id)
    {:reply, found, %{documents: documents, history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:store_history_record, {history_id, record}}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    {_old_value, library} =
      library
      |> Map.get_and_update(history_id, &WE.InMemoryStorage.add_record(&1, record))

    {:reply, record, documents, history_record_library: library}
  end

  defp add_record(list, record) do
    new_value =
      case list do
        nil -> [record]
        _ -> [record | list]
      end

    {list, new_value}
  end

  @impl GenServer
  def handle_call({:find_all_history_records, history_id}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    records =
      library
      |> Map.get(history_id, {:error, "not found for #{history_id}"})

    {:reply, records, documents: documents, history_record_library: library}
  end
end

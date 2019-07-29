defmodule WE.InMemoryStorage do
  @moduledoc """
  In-memory storage is an in memory implementation of the
  [WE.StorageAdapter](WE.Adapter.Local.html) behaviour.
  It is a naieve implementation mainly used for testing purposes or to get
  up to speed quickly in dev. The data in this storage is stored in memory
  and won't persist once the application is stopped.
  """
  use GenServer

  @doc """
  Starts the InMemoryStorage server
  """
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Stops the InMemoryStorage server
  """
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @spec store_document(WE.Document.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  def store_document(doc) do
    GenServer.call(__MODULE__, {:store_document, doc})
  end

  @spec update_document(WE.Document.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  def update_document(doc) do
    GenServer.call(__MODULE__, {:update_document, doc})
  end

  @spec find_document(String.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  def find_document(document_name) do
    GenServer.call(__MODULE__, {:find_document, document_name})
  end

  @spec store_history_record(String.t(), WE.HistoryRecord.t()) ::
          {:ok, WE.HistoryRecord.t()} | {:error, Stirng.t()}
  def store_history_record(history_id, record) do
    GenServer.call(__MODULE__, {:store_history_record, history_id, record})
  end

  @spec find_all_history_records(String.t()) :: [WE.HistoryRecord.t()]
  def find_all_history_records(history_id) do
    GenServer.call(__MODULE__, {:find_all_history_records, history_id})
  end

  # callbacks
  @impl GenServer
  def init(_args) do
    {:ok, %{documents: [], history_record_library: %{}}}
  end

  @impl GenServer
  def handle_call({:store_document, document}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    {:reply, {:ok, document},
     %{documents: [document | documents], history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:update_document, document}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    documents =
      documents
      |> Enum.filter(fn doc ->
        not WE.Document.same_name?(doc, document)
      end)

    {:reply, {:ok, document},
     %{documents: [document | documents], history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:find_document, document_name}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    found = WE.Document.find(documents, document_name)
    {:reply, {:ok, found}, %{documents: documents, history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:store_history_record, history_id, record}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    {_old_value, library} =
      library
      |> Map.get_and_update(history_id, &add_record(&1, record))

    {:reply, {:ok, record}, %{documents: documents, history_record_library: library}}
  end

  @impl GenServer
  def handle_call({:find_all_history_records, history_id}, _from, %{
        documents: documents,
        history_record_library: library
      }) do
    records =
      library
      |> Map.get(history_id, [])

    {:reply, {:ok, records}, %{documents: documents, history_record_library: library}}
  end

  defp add_record(list, record) do
    new_value =
      case list do
        nil -> [record]
        _ -> [record | list]
      end

    {list, new_value}
  end
end

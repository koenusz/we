defmodule WE.Adapter.Local do
  @behaviour WE.StorageAdapter
  @moduledoc false

  @impl WE.StorageAdapter
  def store_document(doc) do
    WE.InMemoryStorage.store_document(doc)
  end

  @impl WE.StorageAdapter
  def update_document(doc) do
    WE.InMemoryStorage.update_document(doc)
  end

  @impl WE.StorageAdapter
  def find_document(document_name) do
    WE.InMemoryStorage.find_document(document_name)
  end

  @impl WE.StorageAdapter
  def store_history_record(history_id, record) do
    WE.InMemoryStorage.store_history_record(history_id, record)
  end

  @impl WE.StorageAdapter
  def find_all_history_records(history_id) do
    WE.InMemoryStorage.find_all_history_records(history_id)
  end
end

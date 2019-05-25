defmodule WE.StorageProvider do
  @type t :: module()

  @callback store_document(WE.Document.t()) :: :ok | :error
  @callback update_document(WE.Document.t()) :: :ok | :error
  @callback store_history_record(WE.HistoryRecord.t()) :: :ok | :error
  @callback store_error(Srtring.t()) :: :ok | :error

  @callback find_document(String.t()) :: WE.Document.t()
  @callback find_all_documents :: [WE.Document.t()]
  @callback find_all_history_records :: [WE.HistoryRecord.t()]
end

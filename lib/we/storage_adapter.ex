defmodule WE.StorageAdapter do
  @type t :: module()

  @type document_id :: String.t()
  @type history_id :: String.t()

  @callback store_document(WE.Document.t()) :: :ok | :error
  @callback update_document(WE.Document.t()) :: :ok | :error
  @callback find_document(document_id) :: WE.Document.t()

  @callback store_history_record(history_id, WE.HistoryRecord.t()) :: :ok | :error
  @callback find_all_history_records(history_id) :: [WE.HistoryRecord.t()]
end

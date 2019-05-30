defmodule WE.StorageAdapter do
  @type t :: module()

  @type document_id :: String.t()
  @type history_id :: String.t()

  @callback store_document(WE.Document.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  @callback update_document(WE.Document.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}
  @callback find_document(document_id) :: WE.Document.t() | {:error, String.t()}

  @callback store_history_record(history_id, WE.HistoryRecord.t()) ::
              {:ok, WE.HistoryRecord} | {:error, String.t()}
  @callback find_all_history_records(history_id) :: [WE.HistoryRecord.t()]
end

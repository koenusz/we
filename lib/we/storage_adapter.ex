defmodule WE.StorageAdapter do
  @moduledoc """
    A behaviour for storage adapters. This adapter is responsible for storing the engine's history
    and the documents into a storage solution. By default the `WE.Adapter.Local` is loaded and used.
    It is recommended to only use this in memory adapter in dev and test becasue a restart will
    purge all its data.
  """

  @moduledoc since: "0.1.0"

  @type t :: module()

  @typedoc """
    The name of the document given as parameter in `WE.Document.document/1` during workflow construction.
  """
  @typedoc since: "0.1.0"
  @type document_name :: String.t()

  @typedoc """
    The unique identifier of a history record. This can be any string.
  """
  @typedoc since: "0.1.0"
  @type history_id :: String.t()

  @doc """
    Store a document.
  """
  @doc since: "0.1.0"
  @callback store_document(WE.Document.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}

  @doc """
    Update a document.
  """
  @doc since: "0.1.0"
  @callback update_document(WE.Document.t()) :: {:ok, WE.Document.t()} | {:error, String.t()}

  @doc """
    Find a document by the document's name.
  """
  @doc since: "0.1.0"
  @callback find_document(document_name) :: WE.Document.t() | {:error, String.t()}

  @doc """
    Store a history record.

  """
  @doc since: "0.1.0"
  @callback store_history_record(history_id, WE.HistoryRecord.t()) ::
              {:ok, WE.HistoryRecord} | {:error, String.t()}

  @doc """
    Find a document by `t:history_id/0`
  """
  @doc since: "0.1.0"
  @callback find_all_history_records(history_id) :: [WE.HistoryRecord.t()]
end

defmodule WE.LocalAdapterTest do
  use ExUnit.Case, async: true

  test "store a document and find" do
    doc = WE.Document.document(%{})

    WE.Adapter.Local.store_document(doc)
    {:ok, result} = WE.Adapter.Local.find_document(WE.Document.document_id(doc))

    assert doc == result
  end

  test "update a document" do
    doc = WE.Document.document(%{updated: false})

    WE.Adapter.Local.store_document(doc)
    updated = WE.Document.update_data(doc, %{updated: true})
    WE.Adapter.Local.update_document(updated)

    {:ok, result} = WE.Adapter.Local.find_document(WE.Document.document_id(doc))

    assert updated == result
  end

  test "store and find history records" do
    doc1 = WE.Document.document(%{nr: 1})
    doc2 = WE.Document.document(%{nr: 2})
    record1 = WE.HistoryRecord.record_document(doc1)
    record2 = WE.HistoryRecord.record_document(doc2)

    WE.Adapter.Local.store_history_record("test_id", record1)
    WE.Adapter.Local.store_history_record("test_id", record2)

    assert WE.Adapter.Local.find_all_history_records("test_id") == {:ok, [record1, record2]}
  end
end

defmodule WE.Document do
  use TypedStruct

  @moduledoc """
    This module represents a piece of required or optional data that can be attached to
    a workflow step or a workflow in general.
  """
  @moduledoc since: "0.1.0"

  @type document_type :: :required | :optional
  @type document_status :: :complete | :incomplete

  typedstruct enforde: true, opaque: true do
    field :name, String.t()
    field :data, map()
    field :type, document_type(), default: :required
    field :status, document_status(), default: :complete
  end

  @doc """
    Create a document. By default a document is required.

    The same document name can only be used once per workflow.
  """
  @doc since: "0.1.0"
  @spec document(String.t()) :: WE.Document.t()
  def document(name) do
    %WE.Document{name: name, data: %{}}
  end

  @doc """
    Create an optional document.

  """
  @doc since: "0.1.0"
  @spec optional_document(String.t()) :: WE.Document.t()
  def optional_document(name) do
    %WE.Document{name: name, data: %{}, type: :optional}
  end

  @spec from_reference(WE.DocumentReference.t()) :: WE.Document.t()
  def from_reference(ref) do
    %WE.Document{
      name: WE.DocumentReference.name(ref),
      data: %{},
      type: WE.DocumentReference.type(ref)
    }
  end

  @doc """
  Retrieve the name form a document struct.
  """
  @doc since: "0.1.0"
  @spec name(WE.Document.t()) :: String.t()
  def name(%WE.Document{} = doc) do
    doc.name
  end

  @doc """
    Retrieve the data attached to this document.
  """
  @doc since: "0.1.0"
  @spec data(WE.Document.t()) :: map()
  def data(%WE.Document{} = doc) do
    doc.data
  end

  @spec type(WE.Document.t()) :: document_type()
  def type(%WE.Document{} = doc) do
    doc.type
  end

  @spec is_required?(WE.Document.t()) :: boolean
  def is_required?(%WE.Document{} = doc) do
    doc.type == :required
  end

  @spec is_optional?(WE.Document.t()) :: boolean
  def is_optional?(%WE.Document{} = doc) do
    doc.type == :optional
  end

  @spec is_complete?(WE.Document.t()) :: boolean
  def is_complete?(%WE.Document{} = doc) do
    doc.status == :complete
  end

  @spec set_document_complete(WE.Document.t()) :: WE.Document.t()
  def set_document_complete(%WE.Document{} = doc) do
    %{doc | status: :complete}
  end

  @spec set_document_is_incomplete(WE.Document.t()) :: WE.Document.t()
  def set_document_is_incomplete(%WE.Document{} = doc) do
    %{doc | status: :incomplete}
  end

  @spec same_name?(WE.Document.t(), WE.Document.t()) :: boolean
  def same_name?(%WE.Document{} = doc1, %WE.Document{} = doc2) do
    doc1.name == doc2.name
  end

  @spec has_name?(WE.Document.t(), String.t()) :: boolean
  def has_name?(%WE.Document{} = doc, document_name) do
    doc.name == document_name
  end

  @spec find([WE.Document.t()], String.t()) :: WE.Document.t()
  def find(documents, name) do
    documents
    |> Enum.find({:error, "not found"}, &has_name?(&1, name))
  end

  @spec update_data(WE.Document.t(), term()) :: WE.Document.t()
  def update_data(document, data) do
    %{document | data: data}
  end
end

defmodule WE.DocumentDefinition do
  use TypedStruct

  typedstruct enforce: true do
    field :name, String.t()
    field :optional, boolean, default: false
    field :attached_to, WE.Task.t() | WE.Event.t(), enforce: false
  end
end

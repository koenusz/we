defmodule WE.Document do
  use TypedStruct

  @type document_type :: :required | :optional

  typedstruct enforde: true, opaque: true do
    field :id, String.t()
    field :data, map()
    field :type, document_type(), default: :required
    field :status, document_status(), default: :complete
  end

  @type document_status :: :complete | :incomplete

  @spec document(map()) :: WE.Document.t()
  def document(%{} = data) do
    %WE.Document{id: WE.Helpers.id(), data: data}
  end

  @spec optional_document(map()) :: WE.Document.t()
  def optional_document(%{} = data) do
    %WE.Document{id: WE.Helpers.id(), data: data, type: :optional}
  end

  @spec document_id(WE.Document.t()) :: String.t()
  def document_id(%WE.Document{} = doc) do
    doc.id
  end

  @spec document_type(WE.Document.t()) :: document_type()
  def document_type(%WE.Document{} = doc) do
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

  @spec same_id?(WE.Document.t(), WE.Document.t()) :: boolean
  def same_id?(%WE.Document{} = doc1, %WE.Document{} = doc2) do
    doc1.id == doc2.id
  end

  @spec has_id?(WE.Document.t(), String.t()) :: boolean
  def has_id?(%WE.Document{} = doc, document_id) do
    doc.id == document_id
  end

  @spec find([Document.t()], String.t()) :: Document.t()
  def find(documents, document_id) do
    documents
    |> Enum.find({:error, "not found"}, fn doc -> has_id?(doc, document_id) end)
  end

  @spec update_data(Document.t(), term()) :: Document.t()
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

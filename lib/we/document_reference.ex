defmodule WE.DocumentReference do
  use TypedStruct

  typedstruct enforde: true, opaque: true do
    field :id, String.t()
    field :type, WE.Document.document_type()
    field :step_name, String.t()
  end

  @spec document_reference(WE.Document.t(), String.t()) :: WE.DocumentReference.t()
  def document_reference(document, step_name) do
    %WE.DocumentReference{
      id: WE.Document.document_id(document),
      type: WE.Document.document_type(document),
      step_name: step_name
    }
  end

  @spec id(WE.DocumentReference.t()) :: String.t()
  def id(ref) do
    ref.id
  end

  @spec has_id?(WE.DocumentReference.t(), String.t()) :: boolean
  def has_id?(ref, id) do
    ref.id == id
  end

  @spec has_name?(WE.DocumentReference.t(), String.t()) :: boolean
  def has_name?(ref, step_name) do
    ref.step_name == step_name
  end

  @spec is_required?(WE.DocumentReference.t()) :: boolean
  def is_required?(ref) do
    ref.type == :required
  end
end

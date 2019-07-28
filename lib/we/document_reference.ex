defmodule WE.DocumentReference do
  use TypedStruct

  typedstruct enforde: true, opaque: true do
    field :name, String.t()
    field :type, WE.Document.document_type()
    field :step_name, String.t()
  end

  @spec document_reference(WE.Document.t(), String.t()) :: WE.DocumentReference.t()
  def document_reference(document, step_name) do
    %WE.DocumentReference{
      name: WE.Document.name(document),
      type: WE.Document.type(document),
      step_name: step_name
    }
  end

  @spec name(WE.DocumentReference.t()) :: String.t()
  def name(ref) do
    ref.name
  end

  @spec type(WE.DocumentReference.t()) :: WE.Document.document_type()
  def type(ref) do
    ref.type
  end

  @spec has_name?(WE.DocumentReference.t(), String.t()) :: boolean
  def has_name?(ref, name) do
    ref.name == name
  end

  @spec has_step?(WE.DocumentReference.t(), String.t()) :: boolean
  def has_step?(ref, step_name) do
    ref.step_name == step_name
  end

  @spec is_required?(WE.DocumentReference.t()) :: boolean
  def is_required?(ref) do
    ref.type == :required
  end
end

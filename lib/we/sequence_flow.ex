defmodule WE.SequenceFlow do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :from, String.t()
    field :to, String.t()
    field :default, boolean, default: false
  end

  alias WE.SequenceFlow

  @spec sequenceFlow(String.t(), String.t()) :: WE.SequenceFlow.t()
  def sequenceFlow(from, to) do
    %SequenceFlow{from: from, to: to}
  end

  @spec default(String.t(), String.t()) :: WE.SequenceFlow.t()
  def default(from, to) do
    %SequenceFlow{from: from, to: to, default: true}
  end
end

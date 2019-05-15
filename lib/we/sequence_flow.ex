defmodule WE.SequenceFlow do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :from, String.t()
    field :to, String.t()
    field :default, boolean, default: false
  end

  alias WE.SequenceFlow

  @spec add_sequence_flow(list(WE.SequenceFlow.t()), WE.SequenceFlow.t()) ::
          list(WE.SequenceFlow.t())
  def add_sequence_flow(list, flow) do
    [flow, list]
  end

  @spec sequence_flow(list(WE.SequenceFlow.t()), String.t(), String.t()) ::
          list(WE.SequenceFlow.t())
  def sequence_flow(list, from, to) do
    [%SequenceFlow{from: from, to: to}, list]
  end

  @spec default_sequence_flow(list(WE.SequenceFlow.t()), String.t(), String.t()) ::
          list(WE.SequenceFlow.t())
  def default_sequence_flow(list, from, to) do
    [%SequenceFlow{from: from, to: to, default: true}, list]
  end

  @spec default(String.t(), String.t()) :: WE.SequenceFlow.t()
  def default(from, to) do
    %SequenceFlow{from: from, to: to, default: true}
  end

  @spec no_default(String.t(), String.t()) :: WE.SequenceFlow.t()
  def no_default(from, to) do
    %SequenceFlow{from: from, to: to, default: false}
  end
end

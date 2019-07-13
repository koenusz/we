defmodule WE.SequenceFlow do
  use TypedStruct

  typedstruct enforce: true do
    field :from, String.t()
    field :to, String.t()
    field :default, boolean, default: false
  end

  alias WE.SequenceFlow

  @spec flow_in_names?(WE.SequenceFlow.t(), [String.t()]) :: boolean
  def flow_in_names?(flow, names) do
    Enum.member?(names, flow.from) and Enum.member?(names, flow.to)
  end

  @spec get_default_flows([WE.SequenceFlow.t()]) :: [WE.SequenceFlow.t()]
  def get_default_flows(list) do
    list
    |> Enum.filter(fn flow -> flow.default end)
  end

  @spec from(WE.SequenceFlow.t()) :: String.t()
  def from(flow) do
    flow.from
  end

  @spec from_equals(WE.SequenceFlow.t(), String.t()) :: boolean
  def from_equals(flow, name) do
    flow.from == name
  end

  @spec to(WE.SequenceFlow.t()) :: String.t()
  def to(flow) do
    flow.to
  end

  # constructors

  @spec sequence_flow(String.t(), String.t()) ::
          WE.SequenceFlow.t()
  def sequence_flow(from, to) do
    %SequenceFlow{from: from, to: to}
  end

  @spec default(String.t(), String.t()) :: WE.SequenceFlow.t()
  def default(from, to) do
    %SequenceFlow{from: from, to: to, default: true}
  end
end

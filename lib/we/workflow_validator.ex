defmodule WE.WorkflowValidator do
  alias WE.{Workflow}

  @spec validate(Workflow.t()) :: :ok | [{:error, String.t()}]
  def validate(workflow) do
    result =
      []
      |> has_start?(workflow)
      |> has_end?(workflow)
      |> Enum.reject(fn item -> item == :ok end)

    case result do
      [] -> :ok
      x -> x
    end
  end

  defp has_start?(list, workflow) do
    test =
      workflow.steps
      |> Enum.map(&Map.get(&1, :type))
      |> Enum.member?(:start)

    if test do
      [:ok | list]
    else
      [{:error, "has no start event"} | list]
    end
  end

  defp has_end?(list, workflow) do
    test =
      workflow.steps
      |> Enum.map(&Map.get(&1, :type))
      |> Enum.member?(:end)

    if test do
      [:ok | list]
    else
      [{:error, "has no end event"} | list]
    end
  end

  # defp step_names_unique?() do
  # end

  # defp each_step_has_default_sequence_flow() do
  # end
end

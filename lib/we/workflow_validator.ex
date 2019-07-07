defmodule WE.WorkflowValidator do
  @spec validate(WE.Workflow.t()) :: :ok | no_return
  def validate(workflow) do
    workflow
    |> has_start?()
    |> has_end?()
    |> step_names_unique?()

    :ok
  end

  defp has_start?(workflow) do
    test =
      workflow
      |> WE.Workflow.get_steps()
      |> Enum.map(&WE.State.content_type(&1))
      |> Enum.member?(:start)

    unless test do
      raise WE.ValidationError,
        message: "workflow #{WE.Workflow.name(workflow)} has no start event"
    end

    workflow
  end

  defp has_end?(workflow) do
    test =
      workflow
      |> WE.Workflow.get_steps()
      |> Enum.map(&WE.State.content_type(&1))
      |> Enum.member?(:end)

    unless test do
      raise WE.ValidationError, message: "workflow #{WE.Workflow.name(workflow)} has no end event"
    end

    workflow
  end

  defp step_names_unique?(workflow) do
    steps =
      workflow
      |> WE.Workflow.get_steps()

    test =
      steps
      |> Enum.map(&WE.Workflow.name(&1))
      |> Enum.uniq()
      |> Kernel.length()
      |> (fn uniq_length -> uniq_length == length(steps) end).()

    unless test do
      raise WE.ValidationError,
        message: "The steps in workflow #{WE.Workflow.name(workflow)} have duplicate names"
    end

    workflow
  end

  # defp each_step_has_default_sequence_flow() do
  # end
end

defmodule WE.ValidationError do
  defexception message: "Validation error"
end

defmodule WE.WorkflowValidator do
  @spec validate(WE.Workflow.t()) :: WE.Workflow.t() | no_return
  def validate(workflow) do
    workflow
    |> has_start?()
    |> has_end?()
    |> step_names_unique?()
    |> sequence_flows_has_existing_steps()
    |> all_steps_have_default_flow_out()
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

  defp sequence_flows_has_existing_steps(workflow) do
    step_names =
      WE.Workflow.get_steps(workflow)
      |> Enum.map(&WE.State.name/1)

    test =
      WE.Workflow.sequence_flows(workflow)
      |> Enum.all?(fn flow -> WE.SequenceFlow.flow_in_names?(flow, step_names) end)

    unless test do
      raise WE.ValidationError,
        message: "A sequenceflow has non existing steps"
    end

    workflow
  end

  defp all_steps_have_default_flow_out(workflow) do
    default_from =
      workflow
      |> WE.Workflow.sequence_flows()
      |> WE.SequenceFlow.get_default_flows()
      |> Enum.map(&WE.SequenceFlow.from(&1))

    test =
      workflow
      |> WE.Workflow.get_steps()
      |> Enum.filter(&WE.State.not_is_end_event?(&1))
      |> Enum.map(&WE.State.name(&1))
      |> Enum.all?(&Enum.member?(default_from, &1))

    unless test do
      raise WE.ValidationError,
        message: "all steps need a default out flow, except end events"
    end

    workflow
  end

  # defp each_step_has_default_sequence_flow() do
  # end
end

defmodule WE.ValidationError do
  defexception message: "Validation error"
end

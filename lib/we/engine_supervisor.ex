defmodule WE.EngineSupervisor do
  use DynamicSupervisor

  @spec start_link([module()]) :: {:error, any} | {:ok, pid}
  def start_link(storage_adapters) do
    DynamicSupervisor.start_link(__MODULE__, storage_adapters, name: __MODULE__)
  end

  @spec init([module()]) ::
          {:ok,
           %{
             extra_arguments: [any],
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(storage_adapters) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [storage_adapters]
    )
  end

  @spec add_engine(String.t(), WE.Workflow.t()) ::
          {:error, any} | {:ok, pid} | {:ok, pid, any}
  def add_engine(business_id, workflow) do
    child_spec = {WE.Engine, [business_id, workflow]}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec children :: [{:undefined, :restarting | pid, :supervisor | :worker, any}]
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  @spec count_children :: %{
          active: non_neg_integer,
          specs: non_neg_integer,
          supervisors: non_neg_integer,
          workers: non_neg_integer
        }
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end

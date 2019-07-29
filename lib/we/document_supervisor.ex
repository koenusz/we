defmodule WE.DocumentSupervisor do
  use DynamicSupervisor
  @moduledoc false
  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_library(history_id, workflow, storage_adapters) do
    child_spec = {WE.DocumentLibrary, {history_id, workflow, storage_adapters}}

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end

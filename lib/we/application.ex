defmodule WE.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    storage_adapters = []

    children = [
      # Starts a worker by calling: WE.Worker.start_link(arg)
      # {WE.Worker, arg}
      {Registry, [keys: :unique, name: :document_registry]},
      WE.DocumentSupervisor,
      %{id: WE.EngineSupervisor, start: {WE.EngineSupervisor, :start_link, [storage_adapters]}}
    ]

    # add an in memory storage provider in case none are defined.
    children =
      case storage_adapters do
        [] ->
          [{WE.InMemoryStorage, []} | children]
          # _ -> children
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WE.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

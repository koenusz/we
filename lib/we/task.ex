defmodule WE.Task do
  use TypedStruct

  typedstruct enforce: true, opaque: true do
    field :name, String.t()
    field :links, list(Link.t())
    field :command, atom()
    field :gateway, atom()
  end

  def next(task, data) do
    task.links[0]
  end
end

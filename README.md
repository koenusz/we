# WE

## purpose of a workflow engine

A workflow engine provides an application with the following features:
* providing visibility of the state of your application
* auditing business processes
* orchestration within an application.

When your application requires one or more of these features this library might be a solution for you.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `we` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:we, "~> 0.1.0"}
  ]
end
```

Start the application in your mix.exs file of your project.

```elixir
def application do
  [
    extra_applications: [:logger],
    mod: {WE.Application, [storage_adapters: []]}
  ]
end
```

## The api

The `WE` module functions as an api. Except for constructing a workflow, all the interactions with this library are done through this module.

## Creating a workflow

The `WE.Workflow` module is used to define workflows. 

example:
```elixir
Workflow.workflow("message event workflow")
|> Workflow.add_start_event("start")
|> Workflow.add_message_event("receive message")
|> Workflow.add_end_event("stop")
|> Workflow.add_default_sequence_flow("start", "receive message")
|> Workflow.add_default_sequence_flow("message", "stop")
```

For more examples take a look at `WE.TestWorkflowHelpers`.

## Starting the engine

The `WE.Engine` module is the heart of this library. It can be contrilled form the `WE` api module.
There are two steps that need to be taken before a workflow is running. The engine needs to be initialised and after
this is one it needs to be started.

```elixir
{:ok, engine_pid} =  init_engine("your business_id", my_workflow)

"your business_id"
|> start_engine("your business_id")

```

During initialization the workflow is validated. Take a look at `WE.Workflow.Validator` to see which validations are done.

## Using a workflow in your application

The workflow engine is updated through the api.

```elixir
def start_doing_something(args)
  ...

  WE.start_task("your business id", "task_name")
  ... do the task
end

def complete doing something(args)

  WE.complete_task("your business id", "task_name")
end
```

After a step in the workflow is done there are two ways to go to the next step. The first one is just follow the outgoing 
default sequence flow. But there is also the possibility to follow one or more non default flows. This is done by adding 
a list of names of the next steps to the `WE.complete_task` or `WE.handle_event/3`

### Documents

Each workflow or each step (except start and end events) within a workflow can have a document attached to it. A document is a piece of business data that is needed to make decisions within the workflow. Documents are defined on a workflow and the engine will check if a required document is 
added before it will move on to a next state.

!A word of caution. Do not use these documents to store large binaries or enormous maps. It is intended for a small collection of workflow relevant
data. If you need to work with big data items it is recommended to store it seperately in a database and use a unique reference id and optionally some meta data on the data item.

### Storage_adapters
  In development an in memory storage adapter is loaded. For production it is advisable to pass a storage adapter that
  provides storage to your storage solution (example: Postgresql). A storage asapter needs to implement the `WE.storage.Adapter` behaviour.


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/we](https://hexdocs.pm/we).


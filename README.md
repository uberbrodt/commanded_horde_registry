
# CommandedHordeRegistry

  Process registration and distribution via [Horde](https://github.com/derekkraan/horde)

  In order to use this, you will need to update the following config values:

  ```elixir
  config :commanded,
    registry: Commanded.Registration.HordeRegistry,
    aggregate_supervisor_mfa:
      {Horde.Supervisor, :start_link,
       [[name: Commanded.Aggregates.Supervisor, strategy: :one_for_one]]}
  ```

  You will also need to join the Supervisors together (connecting them via Distributed Erlang is not
  enough) via `Horde.Cluster` as documented. Starting a `Commanded.Registration.HordeRegistry.Linker`
  in your supervision tree will accomplish this, and has the added benefit of continually checking
  the cluster for new members and joining them.


## Example Usage
To correctly handle dynamic cluster membership or node down events, you will
need to start a `Commanded.Registration.HordeRegistry.Linker` process per a
`Horde.Supervisor` or `Horde.Registry`.

```elixir

defmodule ExampleCommandedApp.EventHandlerSupervisor do
  use Horde.Supervisor
  
  def init(_) do
    cluster_members = Commanded.Registration.HordeRegistry.get_cluster_members(__MODULE__)
    opts = [members: cluster_members, distribution_strategy: Horde.UniformDistribution]
    {:ok, opts}
  end
end


defmodule ExampleCommandedApp do

  use Application

  def start(_, _) do
    children = [
      {Commanded.Registration.HordeRegistry.Linker, [horde_name: Commanded.Registration.HordeRegistry]},
      ExampleCommandedApp.EventHandlerSupervisor,
      {Commanded.Registration.HordeRegistry.Linker, [horde_name: ExampleCommandedApp.EventHandlerSupervisor]},
    ]
  end

end
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `commanded_horde_registry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:commanded_horde_registry, "~> 0.4.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/commanded_horde_registry](https://hexdocs.pm/commanded_horde_registry).


## Development Status

Commanded and Horde have released updates so this is ready for testing. Once I'm
confident it works I'll push a 1.0 release


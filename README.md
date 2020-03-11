
# CommandedHordeRegistry

  Process registration and distribution via [Horde](https://github.com/derekkraan/horde)

  In order to use this, you will need to update your commanded config

  ```elixir
  config :your_app, YourCommandedApp,
    registry: Commanded.Registration.HordeRegistry
  ```


## Installation

Add the following to your mix.exs deps:

```elixir
    {:commanded_horde_registry, "~> 1.0.0-alpha.0"}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/commanded_horde_registry](https://hexdocs.pm/commanded_horde_registry).


## Development Status

I've updated to Horde 0.7 and now am targeting Commanded 1.0. One thing to note
is that we are only providing a distributed process registry. The
`Commanded.Aggregate.Supervisor` will still be a basic DynamicSupervisor and
aggregates will not be restarted in the event of a node exit.



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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `commanded_horde_registry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:commanded_horde_registry, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/commanded_horde_registry](https://hexdocs.pm/commanded_horde_registry).


## Development Status

Currently we have everything we need in Commanded after
[this](https://github.com/commanded/commanded/pull/277) and
[this](https://github.com/commanded/commanded/pull/273) were accepted. Currently
(2019-05-21) those patches are not released, however the master branch seems
stable at the moment.

I'm also working with Horde an issue I identified
[here](https://github.com/derekkraan/horde/issues/116). Once this is resolved, I
will work towards a release candidate. A 1.0 release will likely wait until
Commanded v0.19 is released.

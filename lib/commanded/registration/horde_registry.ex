defmodule Commanded.Registration.HordeRegistry do
  @moduledoc """
  Process registration and distribution via [Horde](https://github.com/derekkraan/horde)

  In order to use this, you will need to update the following config values:

  ```
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
  """

  @behaviour Commanded.Registration

  @impl Commanded.Registration
  def child_spec do
    [Horde.Registry.child_spec(name: __MODULE__, keys: :unique)]
  end

  @impl Commanded.Registration
  def supervisor_child_spec(module, _args) do
    defaults = [
      strategy: :one_for_one,
      distribution_strategy: Horde.UniformDistribution,
      name: module
    ]
    opts = Keyword.merge(defaults, Application.get_env(:commanded_horde_registry, :supervisor_opts))
    Horde.Supervisor.child_spec(opts)
  end

  @impl Commanded.Registration
  def start_child(name, supervisor, {module, args}) do
    via_name = via_tuple(name)
    updated_args = Keyword.put(args, :name, via_name)

    fun = fn ->
      spec = Supervisor.child_spec({module, updated_args}, id: {module, name})
      Horde.Supervisor.start_child(supervisor, spec) end
    start(name, fun)
  end

  @impl Commanded.Registration
  def start_link(name, supervisor, args) do
    via_name = via_tuple(name)

    fun = fn -> GenServer.start_link(supervisor, args, name: via_name) end
    start(name, fun)
  end

  @impl Commanded.Registration
  def whereis_name(name) do
    case Horde.Registry.whereis_name({__MODULE__, name}) do
      pid when is_pid(pid) -> pid
      :undefined -> :undefined
    end
  end

  @impl Commanded.Registration
  def via_tuple(name) do
    {:via, Horde.Registry, {__MODULE__, name}}
  end

  defp start(name, func) do
    case func.() do
      {:error, {:already_started, nil}} ->
        case whereis_name(name) do
          pid when is_pid(pid) -> {:ok, pid}
          _other -> {:error, :registered_but_dead}
        end

      {:error, {:already_started, pid}} when is_pid(pid) ->
        {:ok, pid}

      {:ok, nil} ->
        {:error, :received_ok_nil}

      reply ->
        reply
    end
  end
end

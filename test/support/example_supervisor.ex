defmodule Commanded.HordeRegistry.ExampleSupervisor do
  @moduledoc false
  use Horde.DynamicSupervisor
  use Commanded.Registration
  alias Commanded.HordeRegistry.SupervisedServer

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    [strategy: :one_for_one, members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  defp members() do
    []
  end

  def start_child(name) do
    Registration.start_child(name, __MODULE__, {SupervisedServer, []})
  end
end

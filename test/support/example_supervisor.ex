defmodule Commanded.HordeRegistry.ExampleSupervisor do
  @moduledoc false
  use DynamicSupervisor
  use Commanded.Registration
  alias Commanded.HordeRegistry.SupervisedServer

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    [strategy: :one_for_one]
    |> Keyword.merge(init_arg)
    |> DynamicSupervisor.init()
  end

  def start_child(adapter_meta, name) do
    Registration.start_child(adapter_meta, name, __MODULE__, {SupervisedServer, []})
  end
end

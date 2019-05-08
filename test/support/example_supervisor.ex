defmodule Commanded.HordeRegistry.ExampleSupervisor do
  @moduledoc false
  use Horde.Supervisor
  use Commanded.Registration
  alias Commanded.HordeRegistry.SupervisedServer

  def init(args) do
    {:ok, args}
  end

  def start_child(name) do
    Registration.start_child(name, __MODULE__, {SupervisedServer, []})
  end
end

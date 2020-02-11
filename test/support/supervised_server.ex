defmodule Commanded.HordeRegistry.SupervisedServer do
  use GenServer
  use Commanded.Registration

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def start_link(application, _args) do
    Registration.start_link(application, "supervisedchild", __MODULE__, [])
  end

  def init(state), do: {:ok, state}
end

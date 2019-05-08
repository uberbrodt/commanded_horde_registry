defmodule Commanded.Registration.HordeRegistry.Linker do
  @moduledoc """
  A GenServer process that will monitor cluster membership and join the `Commanded.Registration.HordeRegistry`
  processes running on each node. Also will attempt to connect hordes periodically. Must be started
  after the `Commanded.Registration.HordeRegistry`.
  """
  use GenServer
  require Logger
  alias Commanded.Registration.HordeRegistry, as: CommandedHordeRegistry

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(args) do
    connect_hordes()
    :net_kernel.monitor_nodes(true)
    sync_interval = Keyword.get(args, :sync_interval, 60_000)
    Process.send_after(self(), :connect_hordes, sync_interval)
    {:ok, %{sync_interval: sync_interval}}
  end

  @impl GenServer
  def handle_info({:nodeup, node}, state) do
    Logger.debug(fn -> "Received :nodeup message from #{inspect(node)}" end)
    Horde.Cluster.set_members(CommandedHordeRegistry, [{CommandedHordeRegistry, node}])
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodedown, node}, state) do
    Logger.debug(fn -> "Received :nodedown message from #{inspect(node)}" end)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:connect_hordes, %{sync_interval: si} = state) do
    Process.send_after(self(), :connect_hordes, si)
    connect_hordes()
    {:noreply, state}
  end

  def connect_hordes do
    Enum.each(Node.list(), fn node ->
      Horde.Cluster.set_members(CommandedHordeRegistry, [{CommandedHordeRegistry, node}])
    end)
  end

end

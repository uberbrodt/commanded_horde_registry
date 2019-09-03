defmodule Commanded.Registration.HordeRegistry.Linker do
  @moduledoc """
  A GenServer process that will monitor cluster membership and join the `Commanded.Registration.HordeRegistry`
  processes running on each node. Also will attempt to connect hordes periodically. Must be started
  after the `Commanded.Registration.HordeRegistry`.
  """
  use GenServer
  require Logger
  import Commanded.Registration.HordeRegistry.Util

  @typedoc """
  - sync_interval: an integer in milliseconds that controls how often the cluster membership is
  checked and corrected if stale.
  - horde_name: Name of the Horde.Supervisor or Horde.Registry that will be linked.
  """
  @type opts :: {:sync_interval, pos_integer()}

  @default_sync_interval 60_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Keyword.get(args, :name, __MODULE__))
  end

  @impl GenServer
  def init(args) do
    sync_interval = Keyword.get(args, :sync_interval, @default_sync_interval)
    name = Keyword.get(args, :horde_name, Commanded.Registration.HordeRegistry)

    Process.send_after(self(), :sync_interval, sync_interval)
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, %{sync_interval: sync_interval, horde_name: name}}
  end

  @impl GenServer
  def handle_info({:nodeup, node, _}, %{horde_name: horde_name} = state) do
    Logger.debug(fn -> "Received :nodeup message from #{inspect(node)}" end)
    :ok = Horde.Cluster.set_members(horde_name, get_cluster_members(horde_name))
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodedown, node, _}, %{horde_name: horde_name} = state) do
    Logger.debug(fn -> "Received :nodedown message from #{inspect(node)}" end)
    :ok = Horde.Cluster.set_members(horde_name, get_cluster_members(horde_name))
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:heartbeat, %{sync_interval: si, horde_name: name} = state) do
    Process.send_after(self(), :connect_hordes, si)
    horde_members = Horde.Cluster.members(name) |> untag() |> Enum.sort()
    cluster_members = get_cluster_members(name) |> Enum.sort()

    if cluster_members != horde_members do
      Logger.warn("EntityRegistry cluster membership inconsistent with cluster state. Fixing...")
      :ok = Horde.Cluster.set_members(name, cluster_members)
      Logger.warn("EntityRegistry cluster membership set")
    end

    {:noreply, state}
  end
end

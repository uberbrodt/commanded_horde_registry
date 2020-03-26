defmodule Commanded.Registration.HordeRegistry.NodeListener do
  @moduledoc """
  This process listens for Nodes entering and leaving the cluster and adjusts the Horde.Registry
  members as necessary.
  """
  use GenServer
  import Commanded.Registration.HordeRegistry.Util

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl GenServer
  def init(opts) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    hordes = opts[:hordes]

    case hordes do
      x when is_list(x) -> {:ok, hordes}
      _ -> {:stop, ":hordes must be a list"}
    end
  end

  @impl GenServer
  def handle_info({:nodeup, _, _}, hordes) do
    Enum.each(hordes, fn horde ->
      set_members(horde)
    end)

    {:noreply, hordes}
  end

  @impl GenServer
  def handle_info({:nodedown, _, _}, hordes) do
    Enum.each(hordes, fn horde ->
      set_members(horde)
    end)

    {:noreply, hordes}
  end

  defp set_members(name) do
    members = get_cluster_members(name)
    :ok = Horde.Cluster.set_members(name, members)
  end
end

defmodule Commanded.HordeRegistry.NodeSetup do
  @moduledoc false

  def setup_node(node) do
    rpc(node, Application, :ensure_all_started, [:commanded])
    rpc(node, Commanded.HordeRegistry.DefaultApp, :start_link, [[]])
    args = [name: Commanded.HordeRegistry.ExampleSupervisor, strategy: :one_for_one]
    rpc(node, Commanded.HordeRegistry.ExampleSupervisor, :start_link, [args])
  end

  def rpc(node, module, fun, args) do
    :rpc.block_call(node, module, fun, args)
  end
end

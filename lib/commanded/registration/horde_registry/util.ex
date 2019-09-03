defmodule Commanded.Registration.HordeRegistry.Util do
  @moduledoc false

  def get_cluster_members(name) do
    [Node.self() | Node.list()]
    |> Enum.map(fn node -> {name, node} end)
  end

  def untag({:ok, value}) do
    value
  end

  def untag(value) do
    raise "Expected {:ok, value}, got: #{inspect(value)}"
  end
end

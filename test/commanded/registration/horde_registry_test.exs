defmodule Commanded.Registration.HordeRegistryTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Commanded.Registration
  alias Commanded.Helpers.{ProcessHelper, Wait}
  alias Commanded.HordeRegistry.ExampleSupervisor
  alias Commanded.Registration.RegisteredServer
  alias Commanded.HordeRegistry.DefaultApp

  setup_all do
    nodes = LocalCluster.start_nodes("my-cluster", 3)

    for node <- [Node.self() | nodes] do
      assert Node.ping(node) == :pong
      Commanded.HordeRegistry.NodeSetup.setup_node(node)
    end

    %{application: DefaultApp}
  end

  describe "`start_child/3`" do
    setup do
      on_exit(fn ->
        case Registration.whereis_name(DefaultApp, "child") do
          pid when is_pid(pid) ->
            ProcessHelper.shutdown(pid)

          _ ->
            :ok
        end
      end)
    end

    test "should return child process PID on success", %{application: app} do
      assert {:ok, _pid} = ExampleSupervisor.start_child(app, "child")
    end

    test "should return existing child process when already started", %{application: app} do
      assert {:ok, pid} = ExampleSupervisor.start_child(app, "child")
      assert {:ok, ^pid} = ExampleSupervisor.start_child(app, "child")
    end
  end

  describe "`start_link/3`" do
    setup do
      on_exit(fn ->
        case Registration.whereis_name(DefaultApp, "registered") do
          pid when is_pid(pid) ->
            ProcessHelper.shutdown(pid)

          _ ->
            :ok
        end
      end)
    end

    test "should return process PID on success", %{application: app} do
      assert {:ok, _pid} = start_link(app, "registered")
    end

    test "should return existing process when already started", %{application: app} do
      assert {:ok, _pid} = start_link(app, "registered")
      assert {:ok, _pid} = start_link(app, "registered")

      Wait.until(fn ->
        refute Registration.whereis_name(app, "registered") == :undefined
      end)
    end
  end

  describe "`whereis_name/1`" do
    test "should return `:undefined` when not registered", %{application: app} do
      assert Registration.whereis_name(app, "notregistered") == :undefined
    end

    test "should return PID when child registered", %{application: app} do
      assert {:ok, pid} = ExampleSupervisor.start_child(app, "child")
      assert Registration.whereis_name(app, "child") == pid
    end

    test "should return PID when process registered", %{application: app} do
      assert {:ok, _pid} = start_link(app, "registered")

      Wait.until(fn ->
        refute Registration.whereis_name(app, "registered") == :undefined
      end)
    end
  end

  defp start_link(app, name) do
    Registration.start_link(app, name, RegisteredServer, [name])
  end
end

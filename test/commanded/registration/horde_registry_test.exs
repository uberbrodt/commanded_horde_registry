defmodule Commanded.Registration.HordeRegistryTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Commanded.Registration
  alias Commanded.Helpers.{ProcessHelper, Wait}
  alias Commanded.HordeRegistry.ExampleSupervisor
  alias Commanded.Registration.RegisteredServer

  setup_all do
    nodes = LocalCluster.start_nodes("my-cluster", 3)

    for node <- [Node.self() | nodes] do
      assert Node.ping(node) == :pong
      Commanded.HordeRegistry.NodeSetup.setup_node(node)
    end

    :ok
  end

  describe "`start_child/3`" do
    setup do
      on_exit(fn ->
        case Registration.whereis_name("child") do
          pid when is_pid(pid) ->
            ProcessHelper.shutdown(pid)

          _ ->
            :ok
        end
      end)
    end

    test "should return child process PID on success" do
      assert {:ok, _pid} = ExampleSupervisor.start_child("child")
    end

    test "should return existing child process when already started" do
      assert {:ok, pid} = ExampleSupervisor.start_child("child")
      assert {:ok, ^pid} = ExampleSupervisor.start_child("child")
    end
  end

  describe "`start_link/3`" do
    setup do
      on_exit(fn ->
        case Registration.whereis_name("registered") do
          pid when is_pid(pid) ->
            ProcessHelper.shutdown(pid)

          _ ->
            :ok
        end
      end)
    end

    test "should return process PID on success" do
      assert {:ok, _pid} = start_link("registered")
    end

    test "should return existing process when already started" do
      assert {:ok, _pid} = start_link("registered")
      assert {:ok, _pid} = start_link("registered")

      Wait.until(fn ->
        refute Registration.whereis_name("registered") == :undefined
      end)
    end
  end

  describe "`whereis_name/1`" do
    test "should return `:undefined` when not registered" do
      assert Registration.whereis_name("notregistered") == :undefined
    end

    test "should return PID when child registered" do
      assert {:ok, pid} = ExampleSupervisor.start_child("child")
      assert Registration.whereis_name("child") == pid
    end

    test "should return PID when process registered" do
      assert {:ok, _pid} = start_link("registered")

      Wait.until(fn ->
        refute Registration.whereis_name("registered") == :undefined
      end)
    end
  end

  defp start_link(name) do
    Registration.start_link(name, RegisteredServer, [name])
  end
end

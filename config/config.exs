import Config

config :commanded_horde_registry, :supervisor_opts, []

if Mix.env() == :test do
  import_config "test.exs"
end

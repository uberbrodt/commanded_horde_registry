import Config

config :commanded_horde_registry, :supervisor_opts, []

if config_env() == :test do
  import_config "test.exs"
end

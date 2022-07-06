import Config

config :commanded,
  assert_receive_event_timeout: 2_000,
  event_store_adapter: Commanded.EventStore.Adapters.InMemory,
  registry: Commanded.Registration.HordeRegistry

config :commanded, Commanded.EventStore.Adapters.InMemory,
  serializer: Commanded.Serialization.JsonSerializer

config :ex_unit,
  capture_log: true,
  assert_receive_timeout: 5_000,
  refute_receive_timeout: 2_000

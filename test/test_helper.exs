:ok = LocalCluster.start()

Application.ensure_all_started(:telemetry)
Application.ensure_all_started(:commanded_horde_registry)

ExUnit.start()

# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :supervisor_phoenix, SupervisorPhoenixWeb.Endpoint,
  url: [host: "localhost", port: System.get_env("PORT") || 4000],
  render_errors: [
    formats: [html: SupervisorPhoenixWeb.ErrorHTML, json: SupervisorPhoenixWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SupervisorPhoenix.PubSub,
  live_view: [signing_salt: "scTcVLKy"],
  adapter: Bandit.PhoenixAdapter


# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :supervisor_phoenix, SupervisorPhoenix.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :libcluster,
  topologies: [
    epmd_example: [
      strategy: Elixir.Cluster.Strategy.Epmd,
      config: [
        timeout: 30_000,
        hosts: [:"a@127.0.0.1", :"b@127.0.0.1"]]]],
        connect: {:net_kernel, :connect_node, []},
        disconnect: {:erlang, :disconnect_node, []},
        list_nodes: {:erlang, :nodes, [:connected]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

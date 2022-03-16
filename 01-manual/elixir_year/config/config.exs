# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :elixir_year, ElixirYearWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ElixirYearWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ElixirYear.PubSub,
  live_view: [signing_salt: "OEpsXuHY"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :elixir_year, ElixirYear.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure batch span processor
# config :opentelemetry, :processors,
#   otel_batch_processor: %{
#     exporter: {:otel_exporter_stdout, []}
#   }

# Configure batch span processor and
# Opentelemetry exporter to export our
# telemetry data directly to the Honeycomb OpenTelemetry endpoint
# For prod you'd likely put this in runtime.exs
  config :opentelemetry, :processors,
    otel_batch_processor: %{
      exporter: {:opentelemetry_exporter, %{
        endpoints: [
          {:https, 'api.honeycomb.io', 443 , [
          ]}
        ],
        headers: [
          {"x-honeycomb-team", System.fetch_env!("HONEYCOMB_API_KEY")},
          {"x-honeycomb-dataset", System.fetch_env!("HONEYCOMB_DATASET")}
        ]
      }}
    }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

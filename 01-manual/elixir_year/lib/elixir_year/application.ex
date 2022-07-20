defmodule ElixirYear.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup()
    # Attach the OpentelemetryEcto handler to repo events if using Ecto
    # OpentelemetryEcto.setup([:elixir_year, :repo])

    children = [
      # Start the Telemetry supervisor
      ElixirYearWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirYear.PubSub},
      # Start the Endpoint (http/https)
      ElixirYearWeb.Endpoint
      # Start a worker by calling: ElixirYear.Worker.start_link(arg)
      # {ElixirYear.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirYear.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirYearWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

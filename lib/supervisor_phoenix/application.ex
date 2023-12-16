defmodule SupervisorPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:"a@localhost", :"b@localhost"]]
      ]
    ]

    children = [
      # Start the Telemetry supervisor
      {Cluster.Supervisor, [topologies, [name: SupervisorPhoenixWeb.ClusterSupervisor]]},
      SupervisorPhoenixWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SupervisorPhoenix.PubSub},
      # Start Finch
      {Finch, name: SupervisorPhoenix.Finch},
      # Start the Endpoint (http/https)
      SupervisorPhoenixWeb.Endpoint,
      Backend.StatisticServer
      # Start a worker by calling: SupervisorPhoenix.Worker.start_link(arg)
      # {SupervisorPhoenix.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SupervisorPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SupervisorPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

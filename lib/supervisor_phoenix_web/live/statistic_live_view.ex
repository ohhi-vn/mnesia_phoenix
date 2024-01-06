defmodule SupervisorPhoenixWeb.StatisticLiveView do
  use SupervisorPhoenixWeb, :live_view
  alias Phoenix.PubSub
  alias SupervisorPhoenix.Backend.StatisticServer
  require Logger

  @pubsub_statistic SupervisorPhoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    topic = "statistic:1"
    if connected?(socket) do
      :ok = PubSub.subscribe(@pubsub_statistic, topic)
    end
    current_users = StatisticServer.get_all_users()
    {:ok, assign(socket, current_users: current_users)}
  end

  @impl true
  def handle_info({:update_user, current_users}, socket) do
    Logger.debug("current users: #{inspect(current_users, pretty: true, limit: :infinity)}")
    {:noreply, assign(socket, current_users: current_users)}
  end

end

defmodule SupervisorPhoenixWeb.StatisticLiveView do
  use SupervisorPhoenixWeb, :live_view
  alias Phoenix.PubSub
  alias Backend.StatisticServer

  @pubsub_statistic SupervisorPhoenix.PubSub

  require Logger
  defmacro f_name() do
      elem(__CALLER__.function, 0)
  end

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
  @spec handle_info({:update_user, any()}, any()) :: {:noreply, any()}
  def handle_info({:update_user, current_users}, socket) do
    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_current_users_#{inspect(current_users, pretty: true, limit: :infinity)}")
    {:noreply, assign(socket, current_users: current_users)}
  end

end

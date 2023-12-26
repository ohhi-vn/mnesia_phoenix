defmodule SupervisorPhoenixWeb.StatisticLiveView do
  use SupervisorPhoenixWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_users: 0)}
  end

end

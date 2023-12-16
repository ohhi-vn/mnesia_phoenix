defmodule Backend.StatisticServer do
  use GenServer

  require Logger
  defmacro f_name() do
      elem(__CALLER__.function, 0)
  end

  ## API
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{current_users: 0}, name: :statistic_server)
  end

  def get_all_users() do
    GenServer.call(:statistic_server, :get_all_users)
  end

  ## Callback
  @impl true
  def init(state) do
    spawn(fn() -> create_table() end)
    {:ok, state}
  end

  @impl true
  def handle_info(:terminate, state) do
    Process.exit(Process.whereis(:statistic_server), :kill)
    {:noreply, state}
  end

  @impl true
  def handle_cast(_, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_all_users, _from, state) do
    {:reply, :mnesia.table_info(:statistic, :size), state}
  end

  @impl true
  def terminate(_reason, _) do
    :ok
  end

  defp create_table() do
    case Node.list() do
      [] ->
        :ok
      nodes ->
        for node <- nodes do
          :mnesia.create_schema([node()] ++ Node.list)
          :mnesia.start()
          :mnesia.change_config(:extra_db_nodes,[node()] ++ Node.list)
          Logger.info("db, mnesia start ok.")
          :mnesia.add_table_copy(:statistic, node, :ram_copies)
          table = :mnesia.create_table(:statistic, attributes: [:id, :name], ram_copies: [node()] ++ Node.list(), type: :ordered_set)
          Logger.info("db, mnesia create result: #{inspect(table)}.")
        end
    end
  end

end

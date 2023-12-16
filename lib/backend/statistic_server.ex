defmodule Backend.StatisticServer do
  use GenServer

  require Logger
  defmacro f_name() do
      elem(__CALLER__.function, 0)
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{current_users: 0}, name: :statistic_server)
  end

  @impl true
  def init(state) do
    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_state_#{inspect(state, pretty: true, limit: :infinity)}")
    # info = :ets.info(:statistic)
    :mnesia.create_schema([node()])
    :mnesia.start()

    Logger.info("db, mnesia start ok.")

    try do
      info = :mnesia.table_info(:statistic, :all)
      Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_info_#{inspect(info, pretty: true, limit: :infinity)}")
      :ok
    catch
      _error, {:aborted, {:no_exists, :statistic, :all}} ->
       Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_no_exist_")
       :ok
    end

    # Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_info_#{inspect(info, pretty: true, limit: :infinity)}")
    # :ets.new(:statistic, [:ordered_set, :named_table])

    table = :mnesia.create_table(:statistic, attributes: [:id, :name], ram_copies: [node()], type: :ordered_set)
    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_table_#{inspect(table, pretty: true, limit: :infinity)}")
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
  def handle_call(_, _from, state) do
    {:reply, :ok, state}
  end

  @impl true
  def terminate(_reason, _) do
    :ok
  end

end

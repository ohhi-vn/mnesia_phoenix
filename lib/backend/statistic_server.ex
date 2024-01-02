defmodule Backend.StatisticServer do
  use GenServer
  alias Phoenix.PubSub

  require Logger
  defmacro f_name() do
      elem(__CALLER__.function, 0)
  end

  @tab :statistic
  @tab_attr [:id, :name]

  @pubsub_statistic SupervisorPhoenix.PubSub
  @topic "statistic:1"

  ## API
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{current_users: 0}, name: :statistic_server)
  end

  def get_all_users() do
    GenServer.call(:statistic_server, :get_all_users)
  end

  def simulate_store_users(num) do
    Enum.each(
      1..num,
      fn _number ->
        write_action = fn ->
          random_num = generate_random_number()
          random_string = generate_random_string()
          id = :erlang.phash2({random_num, random_string})

          :mnesia.write({:statistic, id, random_string})
        end
        :mnesia.transaction(write_action)
      end)

      current_users = get_all_users()
      Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_current_users_#{inspect(current_users, pretty: true, limit: :infinity)}")
      PubSub.broadcast(@pubsub_statistic, @topic, {:update_user, current_users})

  end

  defp generate_random_number() do
    :rand.uniform(100000000)  # Change 100 to the desired upper limit for random numbers
  end

  defp generate_random_string() do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end

  def store_users() do
    write_action = fn ->

      :mnesia.write({:statistic, 1, "foo"})
      :mnesia.write({:statistic, 2, "bar"})
    end

    result = :mnesia.transaction(write_action)
    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_result_#{inspect(result, pretty: true, limit: :infinity)}")

    current_users = get_all_users()
    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_current_users_#{inspect(current_users, pretty: true, limit: :infinity)}")
    PubSub.broadcast(@pubsub_statistic, @topic, {:update_user, current_users})

    # simulate store user here
  end

  def store_users2() do
    write_action = fn ->

      :mnesia.write({:statistic, 3, "aaa"})
      :mnesia.write({:statistic, 4, "cccc"})
    end

    result = :mnesia.transaction(write_action)

    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_result_#{inspect(result, pretty: true, limit: :infinity)}")


    current_users = get_all_users()
    Logger.debug("zlyxtam_debug_fun:#{f_name()}/#{__ENV__.line}_current_users_#{inspect(current_users, pretty: true, limit: :infinity)}")
    PubSub.broadcast(@pubsub_statistic, @topic, {:update_user, current_users})

    # simulate store user here
  end

  def store_users(number) when is_integer(number) do
    # simulate store user here
  end

  def store_users(_number) do
    Logger.error("number should be integer")
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
  def handle_cast({:store_user, id, name}, state) do
    write_action = fn ->
      :mnesia.write({:statistic, id, name})
    end
    :mnesia.transaction(write_action)
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
        :mnesia.create_schema([node()] ++ nodes)
        :mnesia.start()
        :mnesia.change_config(:extra_db_nodes,[node()] ++ nodes)
        Logger.info("db, mnesia start ok.")
        table = :mnesia.create_table(@tab, attributes: @tab_attr,
                                     ram_copies: [node()] ++ nodes, type: :set)
        Logger.info("db, mnesia create result: #{inspect(table)}.")
        # create = :mnesia.add_table_copy(:statistic, node, :ram_copies)
        # Logger.info("zlyxtam create #{inspect(create)}")
    end
  end
end

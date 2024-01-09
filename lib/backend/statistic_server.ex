defmodule SupervisorPhoenix.Backend.StatisticServer do
  use GenServer
  use Task
  alias Phoenix.PubSub

  require Logger

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

    max_concurrency = System.schedulers_online() * 10
    1..num
    |> Task.async_stream(
      fn _i ->
        write_action = fn ->
          random_num = generate_random_number()
          random_string = generate_random_string()
          id = :erlang.phash2({random_num, random_string})

          :mnesia.write({:statistic, id, random_string})
        end
        :mnesia.transaction(write_action)
      end,
      max_concurrency: max_concurrency)
    |> Enum.to_list()
    current_users = get_all_users()
    PubSub.broadcast(@pubsub_statistic, @topic, {:update_user, current_users})
  end

  defp generate_random_number() do
    # Change 1000000000 to the desired upper limit for random numbers
    :rand.uniform(1000000000)
  end

  defp generate_random_string() do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end

  ## Callback
  @impl true
  def init(state) do
    spawn(fn() -> create_table() end)
    Logger.info("start the gen_server successfully: #{inspect(:statistic_server)}.")
    {:ok, state}
  end

  @impl true
  def handle_info(:terminate, state) do
    Logger.info("received terminate message.")
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
        # To know how to store tables on disk, how to load them, and what other
        # nodes they should be synchronized with, Mnesia needs to have
        # something called a `schema`, holding all that information.
        :mnesia.create_schema([node()] ++ nodes)
        :mnesia.start()
        # change a list of nodes that Mnesia is to try to connect to
        :mnesia.change_config(:extra_db_nodes, [node()] ++ nodes)
        Logger.info("db, mnesia start ok.")
        table = :mnesia.create_table(@tab, attributes: @tab_attr,
                                     ram_copies: [node()] ++ nodes, type: :set)
        Logger.info("db, mnesia create result: #{inspect(table)}.")
    end
  end
end

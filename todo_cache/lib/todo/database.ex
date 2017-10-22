defmodule Todo.Database do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.Worker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.Worker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end

  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  defp start_workers(db_folder) do
    for index <- 1..3, into: Map.new do
      {:ok, pid} = Todo.Worker.start_link(db_folder)
      {index - 1, pid}
    end
  end

  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end

  def handle_info(:stop, workers) do
    workers
    |> Map.values
    |> Enum.each(&send(&1, :stop))

    {:stop, :normal, Map.new}
  end
  def handle_info(_, state), do: {:noreply, state}
end

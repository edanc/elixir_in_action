defmodule Todo.SystemSupervisor do
  use Supervisor
  def init(_) do
    processes = [
      supervisor(Todo.Database, ["./persist/"]),
      supervisor(Todo.ServerSupervisor, []),
      worker(Todo.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)

  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end
end

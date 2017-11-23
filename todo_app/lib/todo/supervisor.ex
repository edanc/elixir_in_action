defmodule Todo.Supervisor do
  use Supervisor

  def init(_) do
    processes = [
      supervisor(Todo.SystemSupervisor,[])
    ]
    supervise(processes, strategy: :rest_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end
end

defmodule Todo.Server do
  use GenServer

  def start_link(list_name) do
    IO.puts "Starting todo-server for #{list_name}"
    GenServer.start_link(Todo.Server, list_name, name: via_tupple(list_name))
  end

  defp via_tupple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def update_entry(pid, entry_to_update) do
    GenServer.cast(pid, {:update_entry, entry_to_update})
  end

  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  def init(name) do
    new_todo = Todo.Database.get(name) || Todo.List.new
    {:ok, {name, new_todo}}
  end

  def handle_cast({:add_entry, new_entry}, {name, state}) do
    new_todo_list = Todo.List.add_entry(state, new_entry)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  def handle_cast({:update_entry, entry_id, updater_function}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, entry_id, updater_function)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  def handle_cast({:delete_entry, id}, {name, state}) do
    new_todo_list = Todo.List.delete_entry(state, id)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  def handle_call({:entries, date}, _, {name, state}) do
    {:reply, Todo.List.entries(state, date), {name, state} }
  end
end

defmodule TodoServer do
  def start do
    Process.register(spawn(fn -> loop(TodoList.new) end), :todo_server)
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message ->
        proccess_message(todo_list, message)
    end
    loop(new_todo_list)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def update_entry(entry_to_update) do
    send(:todo_server, {:update_entry, self, entry_to_update})
    receive do
      {:todo_entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  def delete_entry(id) do
    send(:todo_server, {:delete_entry, self, id})
    receive do
      {:todo_entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  def entries(date) do
    send(:todo_server, {:entries, self, date})
    receive do
      {:todo_entries, entries} -> entries
      after 5000 ->
        {:error, :timeout}
    end
  end

  defp proccess_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp proccess_message(todo_list, {:update_entry, caller, entry}) do
    updated = TodoList.update_entry(todo_list, entry)
    send(caller, {:todo_entries, updated})
    updated
  end

  defp proccess_message(todo_list, {:delete_entry, caller, id}) do
    deleted = TodoList.delete_entry(todo_list, id)
    send(caller, {:todo_entries, deleted})
    deleted
  end

  defp proccess_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: Map.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn(entry, todo_list_acc) ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)
    %TodoList{todo_list |
      entries: new_entries,
      auto_id: auto_id + 1
    }
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn(_) -> new_entry end)
  end

  def update_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id
  ) do
    %TodoList{todo_list | entries: Map.delete(entries, entry_id)}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
  end
end

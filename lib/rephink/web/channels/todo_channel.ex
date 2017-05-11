defmodule Rephink.Web.TodoChannel do
  use Rephink.Web, :channel
  import RethinkDB.Query

  def join("todo:list", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @table_name "todos"

  def handle_in("todos", _payload, socket) do
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    Rephink.Web.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end

  def handle_in("insert", %{"todo" => todo}, socket) do
    table(@table_name)
      |> insert(todo)
      |> RethinkDB.run(Rephink.DB)
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    Rephink.Web.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end

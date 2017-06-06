defmodule Rephink.Web.TodoChannel do
  use Rephink.Web, :channel
  alias RethinkDB.Changefeed

  def join("todo:list", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("todos", _payload, socket) do
    Changefeed.call(Rephink.Changefeed, :todos)

    {:noreply, socket}
  end

  def handle_in("insert", %{"todo" => todo}, socket) do
    Changefeed.call(Rephink.Changefeed, {:insert, todo})

    {:noreply, socket}
  end

  def handle_in("update", %{"todo" => todo}, socket) do
    Changefeed.call(Rephink.Changefeed, {:update, todo})

    {:noreply, socket}
  end

  def handle_in("delete", %{"todo" => todo}, socket) do
    Changefeed.call(Rephink.Changefeed, {:delete, todo})

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end

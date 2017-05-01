defmodule Rephink.Web.TodoChannel do
  use Rephink.Web, :channel

  def join("todo:list", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("ping", _payload, socket) do
    Rephink.Web.Endpoint.broadcast!(socket.topic, "pong", %{"response" => "pong"})

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end

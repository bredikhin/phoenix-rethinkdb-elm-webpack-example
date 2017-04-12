defmodule Rephink.Web.PageController do
  use Rephink.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

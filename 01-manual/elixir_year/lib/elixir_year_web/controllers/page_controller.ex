defmodule ElixirYearWeb.PageController do
  use ElixirYearWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

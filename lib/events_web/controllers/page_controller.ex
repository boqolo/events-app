defmodule EventsWeb.PageController do
  use EventsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def fourOfour(conn, _params) do
    conn = 
      conn
      |> put_flash(:error, "That page couldn't be found. Check the url")
    render(conn, "index.html")
  end
end

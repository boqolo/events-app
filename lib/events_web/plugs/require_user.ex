defmodule EventsWeb.Plugs.RequireUser do
  # this is needed for the flash and redirect functions
  use EventsWeb, :controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    if conn.assigns[:currentUser] do
      conn
    else
      conn
      |> put_flash(:error, "You aren't signed in")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end

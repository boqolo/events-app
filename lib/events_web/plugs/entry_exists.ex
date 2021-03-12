defmodule EventsWeb.Plugs.EntryExists do
  # this is needed for the flash and redirect functions
  use EventsWeb, :controller 
  import Plug.Conn

  require Logger
  alias Events.Entries

  def init(opts), do: opts

  def call(conn, params) do
    Logger.debug("ENTRY EXISTS ---> #{inspect(params)}")
    Logger.debug("ENTRY EXISTS ---> #{inspect(conn)}")
    entryIdStr = conn.params["entry_id"]
    cond do
      Entries.entryExists?(String.to_integer(entryIdStr)) -> conn
      true -> 
        conn
        |> put_flash(:error, "That event couldn't be found")
        |> redirect(to: Routes.entry_path(conn, :index))
        |> halt()
    end
  end
end


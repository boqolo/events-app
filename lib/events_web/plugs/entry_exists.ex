defmodule EventsWeb.Plugs.EntryExists do
  # this is needed for the flash and redirect functions
  use EventsWeb, :controller
  import Plug.Conn

  require Logger
  alias Events.Entries

  def init(opts), do: opts

  def call(conn, _params) do
    entryIdStr = conn.params["id"] || "-1"

    validId? =
      String.match?(entryIdStr, ~r/\d+/) && Entries.entryExists?(String.to_integer(entryIdStr))

    cond do
      validId? ->
        conn

      true ->
        conn
        |> put_flash(:error, "That event couldn't be found")
        |> redirect(to: Routes.entry_path(conn, :index))
        |> halt()
    end
  end
end

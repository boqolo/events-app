defmodule EventsWeb.EntryController do
  use EventsWeb, :controller
  require Logger

  alias Events.Entries
  alias Events.Entries.Entry

  def index(conn, _params) do
    entries = Entries.list_entries()
    render(conn, "index.html", entries: entries)
  end

  def new(conn, _params) do
    changeset = Entries.change_entry(%Entry{})
    Logger.debug("EntryController: new ---> " <> inspect(changeset))
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"entry" => entry_params}) do
    formattedParams = 
      entry_params
      |> Map.put("date", convertToDateTime(entry_params["date"]))
      |> Map.put("user_id", conn.assigns[:currentUser].id)

    Logger.debug("Entry controller ---> " <> inspect(formattedParams))

    case Entries.create_entry(formattedParams) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.entry_path(conn, :show, entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp convertToDateTime(dateStr) do
    dateStr
    |> String.replace(", ", "T")
    |> (fn(s) -> s <> ":00" <> "Z" end).()
    |> DateTime.from_iso8601()
    |> elem(1)
    |> DateTime.shift_zone("America/Chicago") # central is my TZ
    |> elem(1)
  end

  def show(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    render(conn, "show.html", entry: entry)
  end

  def edit(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    changeset = Entries.change_entry(entry)
    render(conn, "edit.html", entry: entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "entry" => entry_params}) do
    entry = Entries.get_entry!(id)

    case Entries.update_entry(entry, entry_params) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Entry updated successfully.")
        |> redirect(to: Routes.entry_path(conn, :show, entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", entry: entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    {:ok, _entry} = Entries.delete_entry(entry)

    conn
    |> put_flash(:info, "Entry deleted successfully.")
    |> redirect(to: Routes.entry_path(conn, :index))
  end
end

defmodule EventsWeb.EntryController do
  use EventsWeb, :controller
  require Logger

  alias Events.Entries
  alias Events.Entries.Entry

  alias EventsWeb.Util.Formatting

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
        |> put_flash(:info, "Event created successfully")
        |> redirect(to: Routes.entry_path(conn, :show, entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, Formatting.humanizeChangesetErrors(changeset))
        |> render("new.html", changeset: changeset)
    end
  end

  defp convertToDateTime(dateStr) do
    formattedDateStr = 
      dateStr
      |> String.replace(", ", "T")
      |> (fn(s) -> "#{s}:00Z" end).() # correct ISO format

    case DateTime.from_iso8601(formattedDateStr) do
      {:ok, dateTime, _} -> 
        case DateTime.shift_zone(dateTime, "America/Chicago") do
          {:ok, shiftedDateTime} -> shiftedDateTime
          _ -> dateStr
        end
      _ -> dateStr
    end
  end

  def show(conn, %{"id" => id}) do
    entry = Entries.get_and_load_entry!(id)
    render(conn, "show.html", entry: entry)
  end

  def edit(conn, %{"id" => id}) do
    entry = Entries.get_and_load_entry!(id)
    changeset = Entries.change_entry(entry)
    render(conn, "edit.html", entry: entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "entry" => entry_params}) do
    entry = Entries.get_entry!(id)

    case Entries.update_entry(entry, entry_params) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Entry updated successfully")
        |> redirect(to: Routes.entry_path(conn, :show, entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", entry: entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    entry = Entries.get_entry!(id)
    {:ok, _entry} = Entries.delete_entry(entry)

    conn
    |> put_flash(:info, "Entry deleted successfully")
    |> redirect(to: Routes.entry_path(conn, :index))
  end
end

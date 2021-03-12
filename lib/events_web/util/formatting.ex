defmodule EventsWeb.Util.Formatting do

  require Logger

  def makeURL(conn, localPath) do
    "http://#{conn.host}/#{localPath}"
  end

  def humanizeChangesetErrors(changeset) do
    # Source: Ecto docs at https://hexdocs.pm/ecto/getting-started.html
    errors = 
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    messages = 
      for {field, errorMsgs} <- errors, into: [] do
        errorMsg = Enum.join(errorMsgs, ", ")
        field
        |> Atom.to_string()
        |> (fn(str) -> "#{str} #{errorMsg}" end).()
        |> String.capitalize()
      end
    
    messages
    |> Enum.join(". ")
  end

  def convertUTCDateTime!(dateTime) do
    {:ok, centralDateTime} = DateTime.shift_zone!(dateTime, "America/Chicago")
    centralDateTime
  end

  def convertNaiveDateTime!(naiveDateTime) do
    DateTime.from_naive!(naiveDateTime, "America/Chicago")
  end

  def formatDateTime(dateTime) do 
    # TODO format output
    dateTime
  end

end

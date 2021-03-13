defmodule EventsWeb.Plugs.UserInvite do
  # this is needed for the flash and redirect functions
  use EventsWeb, :controller
  import Plug.Conn

  require Logger
  alias Events.Entries
  alias Events.Invitations

  def init(opts), do: opts

  def call(conn, _params) do
    entry_id =
      conn.params["entry_id"] ||
        conn.params["id"]
        |> String.to_integer()

    unless Entries.entryExists?(entry_id) do
      conn
    else
      # if no entry, pass thru
      # if owner, pass thru 
      # if not user and not invited, pass thru
      # if user and invited, go to ur invitation 
      # if user and not invited, put_flash + redirect to events
      # if not user and invited, redirect to signup + redirect back to invitation
      currentUser = conn.assigns[:currentUser]
      entry = Entries.get_entry(entry_id)

      cond do
        !currentUser ->
          handleUnregisteredUser(conn, entry_id)

        currentUser.id == entry.user_id ->
          conn

        Invitations.userInvited?(currentUser.email, entry_id) ->
          handleInvited(conn, currentUser.email, entry_id)

        true ->
          handleUninvited(conn)
      end
    end
  end

  defp handleUnregisteredUser(conn, entry_id) do
    conn
    |> put_flash(:info, "Sign in or sign up to accept this invitation")
    |> put_session(:alreadyInvited, %{entry_id: entry_id})
    |> redirect(to: Routes.user_path(conn, :new))
    |> halt()
  end

  defp handleInvited(conn, email, entry_id) do
    case Invitations.getInvitationIdByEmail(email, entry_id) do
      [invit_id] ->
        conn
        |> redirect(to: Routes.entry_invitation_path(conn, :show, entry_id, invit_id))
        |> halt()

      _ ->
        conn
        |> put_flash(:error, "There was a problem finding your invitation")
        |> redirect(to: Routes.entry_path(conn, :show, entry_id))
        |> halt()
    end
  end

  defp handleUninvited(conn) do
    conn
    |> put_flash(:error, "You weren't invited to that event")
    |> redirect(to: Routes.entry_path(conn, :index))
    |> halt()
  end
end

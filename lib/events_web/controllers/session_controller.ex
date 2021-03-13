defmodule EventsWeb.SessionController do
  # declaring import of our macros and Phoenix.Controller's macros
  use EventsWeb, :controller

  require Logger

  # Here we need actions that dispatch based on requests (typically func name atoms)

  # If this is called, someone wants to set a `current_user` cookie for a session
  def create(conn, %{"email" => email} = _params) do
    user = Events.Users.getUserByEmail(email)

    # User has an account
    if user do
      conn =
        conn
        |> put_session(:userID, user.id)
        |> put_flash(:info, "Signed in sucessfully")

      # if already invited, redirect, else show user
      Logger.debug("SESSION CONTROLELR alreadyInvited ---?> #{inspect(get_session(conn))}")
      with %{entry_id: entry_id} <- Map.get(get_session(conn), "alreadyInvited") do
        conn
        |> delete_session("alreadyInvited")
        |> redirect(to: Routes.entry_invitation_path(conn, :index, entry_id))
      else
        _ ->
          conn
          |> redirect(to: Routes.user_path(conn, :show, user.id))
      end
    else
      conn
      # may as well delete even if not exist so that next attempt is clean
      |> delete_session(:userID)
      |> put_flash(:error, "Sign in failed. Try another email address or sign up")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:userID)
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end

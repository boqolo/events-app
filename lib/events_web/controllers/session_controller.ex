defmodule EventsWeb.SessionController do
  use EventsWeb, :controller # declaring import of our macros and Phoenix.Controller's macros

  # Here we need actions that dispatch based on requests (typically func name atoms)
  
  # If this is called, someone wants to set a `current_user` cookie for a session
  # TODO check if user in DB. if so, set session to userID and flash welcome,
  # otherwise flash error
  def create(conn, %{"email" => email} = _params) do
    user = Events.Users.getUserByEmail(email)
    if user do
      conn
      |> put_session(:userID, user.id)
      |> put_flash(:info, "Signed in. Welcome back, #{user.name}")
      |> redirect(to: Routes.user_path(conn, :index))
    else
      conn
      |> delete_session(:userID) # may as well try delete even if not exist so that next attempt is clean
      |> put_flash(:error, "Sign in failed. Try another email address")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  # TODO
  def delete(conn, _params) do
    conn
    |> delete_session(:userID)
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: Routes.page_path(conn, :index))
  end

end
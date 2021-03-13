defmodule EventsWeb.Plugs.FetchUser do
  # don't need to prefix functions
  import Plug.Conn
  require Logger

  # A Plug module encapsulates some functionality to do on
  # a connection as it comes in through a request to the
  # server. 
  #
  # All plugs have signature Conn, opts -> Conn
  # which is the Plug.Conn connection struct. It
  # contains a bunch of data about the req + connection.

  def init(opts), do: opts

  def call(conn, _opts) do
    # this is a clever way of denoting there is no session but
    # alowing the line after it not to fail. Querying for id -1
    # will always be nil
    userID = get_session(conn, :userID) || -1
    Logger.debug("Plug: session --> " <> inspect(userID))
    # returns a User struct
    user = Events.Users.get_user(userID)
    Logger.debug("Plug: user ---> " <> inspect(user))

    if user do
      assign(conn, :currentUser, user)
    else
      assign(conn, :currentUser, nil)
    end
  end
end

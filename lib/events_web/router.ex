defmodule EventsWeb.Router do
  use EventsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EventsWeb.Plugs.FetchUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # This block defines al of your app's routes!!! (mix phx.routes shows all)
  # NOTE must restart server when routes updated
  scope "/", EventsWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    resources "/entries", EntryController
    resources "/session", SessionController, # generates Routes.session_path based on controller name 
      only: [:create, :delete], # Since we only ever want to create and delete on sessions
      singleton: true # basically means lone resource not needing id
  end

  # Other scopes may use custom stacks.
  # scope "/api", EventsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: EventsWeb.Telemetry
    end
  end
end

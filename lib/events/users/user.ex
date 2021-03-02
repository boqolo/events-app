defmodule Events.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  # This module is the Schema definition for how Elixir perceives
  # users from the DB

  # i.e. "the things in the table 'users' look like this"
  # If migrations are to Ecto the shape of DB tables, 
  # schemas are to Elixir the shape of Ecto's migrations
  schema "users" do 
    # will autogenerate id field of type integer
    field :name, :string, null: false
    field :email, :string, null: false
    timestamps() # this is a macro that auto adds 'inserted_at' and updated_at' fields
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, min: 2, max: 15)
    |> validate_length(:email, min: 6, max: 20)
    |> validate_format(:email, ~r/@/)
  end

end


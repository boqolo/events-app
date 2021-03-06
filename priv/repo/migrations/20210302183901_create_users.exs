defmodule Events.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  # This is where we tell Ecto how to create a table in our DB
  # (Postgres). Running migrations is a single step

  def change do
    create table(:users) do
      add :name, :string, null: false, default: ""
      add :email, :string, null: false

      timestamps()
    end

  end
end

defmodule Events.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :name, :string
      add :description, :string
      add :date, :utc_datetime
      add :invitees, {:array, :string}

      timestamps()
    end

  end
end

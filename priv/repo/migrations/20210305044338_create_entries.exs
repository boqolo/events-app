defmodule Events.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :name, :string, null: false
      add :description, :text, null: false, default: ""
      add :date, :utc_datetime
      add :user_id, references(:users), null: false # event entries belong to users

      timestamps()
    end

  end
end

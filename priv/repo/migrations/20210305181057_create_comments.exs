defmodule Events.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :string, null: false
      add :entry_id, references(:entries), null: false # comments belong to events
      add :user_id, references(:users), null: false # comments belong to users

      timestamps()
    end

    # this is primarily done as an optimization. it adds indices in a table at the 
    # given columns and maybe makes lookup faster by using them as breakpoints
    # in some way?
    # create(index(:comments, [:entry_id, :user_id]))
  end
end

defmodule Events.Repo.Migrations.AddProfilePhotos do
  use Ecto.Migration

  def change do
    # This 'alters' the Users table to have a photo hash field.
    # When running this migration or rolling back, 
    # Ecto takes care of defining updates and rollbacks
    # with this change function. Alternatively could define
    # and `up` and `down`.
    #
    # It is up to me to update the schema because that is
    # Elixir's interface with the DB. This must be done 
    # every time
    alter table(:users) do
      add :photo_hash, :string, null: false, default: ""
    end 
  end
end

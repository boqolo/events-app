defmodule Events.Entries.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :description, :string
    field :invitees, {:array, :string}
    field :date, :utc_datetime
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:name, :date, :description, :invitees])
    |> validate_required([:name, :date, :descriptions])
  end
end

defmodule Curious.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:typed_table) do
      add :type,      :string
      add :atom_type, :string

      timestamps
    end
  end
end

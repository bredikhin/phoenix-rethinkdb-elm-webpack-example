defmodule Rephink.Rephink.Todo do
  use Ecto.Schema

  schema "todos" do
    field :completed, :boolean, default: false
    field :task, :string

    timestamps()
  end
end

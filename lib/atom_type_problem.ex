defmodule Curious do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Curious.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Curious.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Curious.Repo do
  use Ecto.Repo, otp_app: :curious
end

defmodule Curious.TypedTable do
  use Ecto.Model
  defmodule Type do
    @behaviour Ecto.Type
    def type, do: :string

    def cast(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}
    def cast(_),     do: :error

    def load(value), do: {:ok, String.to_atom(value)}

    def dump(value) when is_atom(value), do: {:ok, Atom.to_string(value)}
    def dump(value) when is_binary(value), do: {:ok, value}
    def dump(_), do: :error
  end

  schema "typed_table" do
    field :type, :string
    field :atom_type, Curious.TypedTable.Type
    timestamps
  end


  def create_monkey do
    %Curious.TypedTable{type: "Curious.MonkeySay", atom_type: :monkey} |> Curious.Repo.insert!
  end

  def create_man_in_yellow_hat do
    %Curious.TypedTable{type: "Curious.ManSay", atom_type: :man} |> Curious.Repo.insert!
  end

  def all do
    Curious.TypedTable |> Curious.Repo.all
  end

  def run_example do
    Curious.TypedTable.create_monkey
    Curious.TypedTable.create_man_in_yellow_hat
    IO.inspect Curious.Repo.all( from t in Curious.TypedTable, where: (t.atom_type == :monkey))
  end
end

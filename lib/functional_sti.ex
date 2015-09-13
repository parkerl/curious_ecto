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

    def cast(atom) when is_atom(atom) do
      IO.puts "In atom"
        {:ok, Atom.to_string(atom)}
    end

    def cast(string) when is_binary(string),     do: {:ok, string}
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
    %Curious.TypedTable{type: "Curious.ManSay", atom_type: "man"} |> Curious.Repo.insert!
  end

  def all do
    Curious.TypedTable |> Curious.Repo.all
  end

  def say(%Curious.TypedTable{type: module_name} = record) do
    say = quote do: Module.concat(__MODULE__, unquote(module_name)).say
    Code.eval_quoted(say)
    IO.inspect record
  end

  def run_example do
    Curious.TypedTable.create_monkey
    Curious.TypedTable.create_man_in_yellow_hat
    Curious.TypedTable.all |> Enum.each  &Curious.TypedTable.say/1
  end
end

defmodule Curious.MonkeySay do
  def say do
    IO.puts "monkey say monkey do"
  end
end

defmodule Curious.ManSay do
  def say do
    IO.puts "george!!"
  end
end


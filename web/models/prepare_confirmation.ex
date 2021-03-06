defmodule Hyperledger.PrepareConfirmation do
  use Ecto.Model
  
  alias Hyperledger.PrepareConfirmation
  alias Hyperledger.LogEntry
  alias Hyperledger.Node
  alias Hyperledger.Repo
  
  schema "prepare_confirmations" do
    field :signature, :string
    field :data, :string
    
    timestamps
    
    belongs_to :log_entry, LogEntry
    belongs_to :node, Node
  end
  
  @required_fields ~w(data signature log_entry_id node_id)
  
  def changeset(params) do
    %PrepareConfirmation{}
    |> cast(params, @required_fields, [])
    |> validate_inclusion(:node_id, Repo.all(from n in Node, select: n.id))
    |> validate_authenticity
  end
  
  def create(changeset) do
    Repo.transaction fn ->
      Repo.insert(changeset)
    end
  end
  
  defp validate_authenticity(changeset) do
    key =
      case Repo.get(Node, changeset.changes.node_id) do
        nil -> ""
        node -> node.public_key
      end
    sig = changeset.changes.signature
    
    validate_change changeset, :data, fn :data, body ->
      case {Base.decode16(key), Base.decode16(sig)} do
        {{:ok, key}, {:ok, sig}} ->
          if :crypto.verify(:ecdsa, :sha256, body, sig, [key, :secp256k1]) do
            []
          else
            [{:data, :authentication_failed}]
          end
        _ -> []
      end
    end
  end
end

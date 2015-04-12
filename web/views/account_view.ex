defmodule Hyperledger.AccountView do
  use Hyperledger.Web, :view
  
  def render("index.json", %{conn: conn, accounts: accounts}) do
    %{
      uber: %{
        version: "1.0",
        data: [
          %{
            rel: ["self"],
            url: account_url(conn, :index)
          },
          %{
            id: "accounts",
            rel: ["collection"],
            data: Enum.map(accounts, fn account ->
              %{
                name: "account",
                rel: ["item"],
                url: account_url(conn, :show, account.public_key),
                data: [
                  %{
                    name: "ledgerHash",
                    value: account.ledger_hash
                  },
                  %{
                    name: "publicKey",
                    value: account.public_key
                  }
                ]
              }
            end)
          }
        ]
      }
    }
  end
  
  def render("show.json", %{conn: conn, account: account}) do
    %{
      uber: %{
        version: "1.0",
        data: [
          %{
            rel: ["self"],
            name: "account",
            url: account_url(conn, :show, account.public_key),
            data: [
              %{
                name: "ledgerHash",
                value: account.ledger_hash
              },
              %{
                name: "publicKey",
                value: account.public_key
              }
            ]
          }
        ]
      }
    }
  end
  
end
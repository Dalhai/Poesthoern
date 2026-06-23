defmodule Posthoern.Application do
  @moduledoc """
  OTP application entry point.

  Starts the supervision tree that runs the relay: a Bandit HTTP server bound to
  the address and port configured in the `:posthoern` application environment
  (set from the environment in `config/runtime.exs`), serving requests through
  `Posthoern.Relay.Endpoint`. The supervisor is registered as
  `Posthoern.Supervisor` and restarts the server one-for-one if it crashes.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit,
       plug: Posthoern.Relay.Endpoint, scheme: :http, ip: bind_address(), port: bind_port()}
    ]

    opts = [strategy: :one_for_one, name: Posthoern.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Bind address as an :inet address tuple. Accepts a dotted/colon string from
  # config; falls back to loopback if it is absent or unparseable.
  defp bind_address do
    :posthoern
    |> Application.get_env(:bind_address, "127.0.0.1")
    |> to_charlist()
    |> :inet.parse_address()
    |> case do
      {:ok, address} -> address
      {:error, _reason} -> {127, 0, 0, 1}
    end
  end

  defp bind_port do
    Application.get_env(:posthoern, :bind_port, 4000)
  end
end

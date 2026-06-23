defmodule Posthoern.Relay.Endpoint do
  @moduledoc """
  HTTP entry plug for the relay.

  A `Plug.Router` that matches incoming requests against the relay's routes and
  dispatches them. It guarantees a response for every request: a known route is
  served by its handler, and any unmatched request receives `404`.

  `GET /health` returns `200` and is side-effect free, so it is safe for an
  uptime probe to call on any schedule.
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "ok")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end

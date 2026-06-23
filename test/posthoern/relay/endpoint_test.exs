defmodule Posthoern.Relay.EndpointTest do
  use ExUnit.Case, async: true
  import Plug.Test

  alias Posthoern.Relay.Endpoint

  @opts Endpoint.init([])

  test "GET /health responds 200" do
    conn = Endpoint.call(conn(:get, "/health"), @opts)

    assert conn.status == 200
  end

  test "an unknown path responds 404" do
    conn = Endpoint.call(conn(:get, "/does-not-exist"), @opts)

    assert conn.status == 404
  end
end

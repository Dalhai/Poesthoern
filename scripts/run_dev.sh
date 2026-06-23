#!/bin/sh
# Launch Pösthörn in development mode with an interactive console.
#
# Starts the supervised OTP application (Bandit + Plug.Router) inside an IEx
# session, so the relay listens locally and you get a shell to inspect it.
# All runtime configuration — the tenant registry, SMTP credentials, bind
# address/port — is read from the environment by config/runtime.exs; this
# script sources ./posthoern.env (gitignored) when present so secrets stay
# out of the repo.

set -eu

cd "$(dirname "$0")/.."

# Load local development environment (gitignored) if it exists.
if [ -f posthoern.env ]; then
  set -a
  . ./posthoern.env
  set +a
fi

exec iex -S mix

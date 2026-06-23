<p align="center">
  <img src="assets/banner.svg" alt="Pösthörn — multi-tenant support-mail relay" width="100%">
</p>

# Pösthörn

Pösthörn is a multi-tenant support-mail relay. It accepts an opaque (already
end-to-end-encrypted) report bundle over HTTP and forwards it as an email
attachment to a fixed per-tenant recipient. It is a supervised Elixir/OTP
application built on [Bandit](https://hex.pm/packages/bandit) + `Plug.Router`
for the HTTP endpoint (no Phoenix), with the SMTP send path arriving in a later
ticket.

## Requirements

- Elixir `~> 1.18` (developed against Elixir 1.20.x)
- Erlang/OTP 27 or newer (developed against OTP 29)

## Local development

Fetch dependencies:

```sh
mix deps.get
```

Run the supervised app in an interactive console. The preferred entry point is
`./scripts/run_dev.sh`, which sources a gitignored `posthoern.env` (when
present) so runtime configuration stays out of the repo, then runs `iex -S mix`:

```sh
./scripts/run_dev.sh
```

`posthoern.env` is a plain shell file of `KEY=value` lines. It is gitignored —
never commit it. A minimal example sets only the non-secret bind options
(secrets such as the tenant registry and SMTP credentials arrive in later
tickets):

```sh
# posthoern.env
BIND_ADDRESS=127.0.0.1
BIND_PORT=4000
```

If you do not need that file, run the app directly:

```sh
iex -S mix
```

Once it is running, hit the health check:

```sh
curl http://127.0.0.1:4000/health
# => 200, body: ok
```

Unknown paths respond `404`.

## Tests & formatting

```sh
mix test
mix format
mix format --check-formatted
mix compile --warnings-as-errors
```

CI runs `mix format --check-formatted`, `mix compile --warnings-as-errors`, and
`mix test` on every push and pull request.

## Configuration

All runtime configuration is read from the environment in
`config/runtime.exs`, so a `mix release` is configured at boot rather than at
compile time. The non-secret bind options:

| Variable       | Default     | Description                                  |
| -------------- | ----------- | -------------------------------------------- |
| `BIND_ADDRESS` | `127.0.0.1` | Address the HTTP endpoint binds to.          |
| `BIND_PORT`    | `4000`      | Port the HTTP endpoint binds to.             |

Secrets — the tenant registry (token → recipient, label, size cap, rate limit)
and the SMTP send path — are wired up by later tickets. They are listed as
placeholder reads in `config/runtime.exs` so the configuration shape is visible,
but no secret value is committed.

## Deployment orientation

Pösthörn is environment-first by design. In production, deliver configuration
through a systemd unit's `EnvironmentFile`, build a `mix release`, and let
`config/runtime.exs` read the environment at boot. This is orientation, not a
full runbook.

## License

Pösthörn is licensed under the GNU Lesser General Public License v3.0. See
[COPYING](COPYING) (GPL-3.0 terms) and [COPYING.LESSER](COPYING.LESSER) (the
additional LGPL-3.0 permissions).

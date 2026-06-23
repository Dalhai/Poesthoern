import Config

# Runtime configuration: every environment read lives here so a `mix release`
# is configured at boot, not at compile time. Never commit secret values; this
# file only reads names and supplies non-secret defaults.

# Bind address/port for the HTTP endpoint. BIND_ADDRESS is parsed into an
# :inet address tuple by Posthoern.Application; BIND_PORT must be an integer.
config :posthoern,
  bind_address: System.get_env("BIND_ADDRESS", "127.0.0.1"),
  bind_port: String.to_integer(System.get_env("BIND_PORT", "4000"))

# Placeholder reads for secrets that later tickets wire up. They are listed
# here so the configuration shape is visible; no secret value is committed.
#
# Tenant registry — maps an opaque token to {recipient, label, size cap,
# rate limit}. Operator-facing key names are a stable contract.
#   config :posthoern, tenant_registry: System.get_env("TENANT_REGISTRY")
#
# SMTP send path (Swoosh), added by a later ticket:
#   config :posthoern, Posthoern.Mailer,
#     relay: System.get_env("SMTP_RELAY_HOST"),
#     port: System.get_env("SMTP_RELAY_PORT", "587"),
#     username: System.get_env("SMTP_USERNAME"),
#     password: System.get_env("SMTP_PASSWORD")

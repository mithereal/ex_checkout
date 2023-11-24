import Config
# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n", level: :info

config :ex_checkout, ExCheckout.Repo,
  username: "postgres",
  password: "postgres",
  database: "ex_checkout",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

import Config
# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :ex_checkout, :ecto_repos, [ExCheckout.Repo.Null]

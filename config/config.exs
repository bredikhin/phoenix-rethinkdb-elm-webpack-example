# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :rephink,
  ecto_repos: [Rephink.Repo]

# Configures the endpoint
config :rephink, Rephink.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fLHqH1cya8iujdZMELrytzIg4YYhyatx5ABee/izfp7EyMp2zG5xMaR1nogET+Co",
  render_errors: [view: Rephink.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Rephink.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :rephink, Rephink.Repo,
  adapter: RethinkDB.Ecto

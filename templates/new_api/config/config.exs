# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

<%= if namespaced? or ecto do %># General application configuration
config :<%= app_name %><%= if namespaced? do %>,
namespace: <%= app_module %><% end %><%= if ecto do %>,
ecto_repos: [<%= app_module %>.Repo]<% end %>

<% end %># Configures the endpoint
config :<%= app_name %>, <%= app_module %>.Endpoint,
url: [host: "localhost"],
secret_key_base: "<%= secret_key_base %>",
render_errors: [view: <%= app_module %>.ErrorView, accepts: ~w(json)],
pubsub: [name: <%= app_module %>.PubSub,
 adapter: Phoenix.PubSub.PG2]

<%= if errors_tracking_app == :sentry do %>
# Configure sentry
config :sentry,
  dsn: "yourdsn",
  environment_name: Mix.env,
  included_environments: [:prod]
<% end %>
<%= if errors_tracking_app == :rollbax do %>
# Configure Rollbax
config :rollbax,
  access_token: "yourtoken",
  environment: "production"

  # We register Rollbax.Logger as a Logger backend.
config :logger,
  backends: [Rollbax.Logger]

# We configure the Rollbax.Logger backend.
config :logger, Rollbax.Logger,
  level: :error
<% end %>

 <%= if jsonapi do %>
 #Configure JSON Api Mime and encoding
 config :phoenix, :format_encoders,
 "json-api": Poison

 config :mime, :types, %{
   "application/vnd.api+json" => ["json-api"]
 }
 <% end %>

 # Configures Elixir's Logger
 config :logger, :console,
 format: "$time $metadata[$level] $message\n",
 metadata: [:request_id]
 <%= generator_config %>
 # Import environment specific config. This must remain at the bottom
 # of this file so it overrides the configuration defined above.
 import_config "#{Mix.env}.exs"

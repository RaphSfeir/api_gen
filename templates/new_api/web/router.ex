defmodule <%= app_module %>.Router do
  use <%= app_module %>.Web, :router

  pipeline :api do
    plug :accepts, ["json-api"]
  end

  scope "/", <%= app_module %> do
    pipe_through :api# Use the default browser stack

  end
end

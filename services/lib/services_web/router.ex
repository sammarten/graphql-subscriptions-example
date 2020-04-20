defmodule ServicesWeb.Router do
  use ServicesWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: ServicesWeb.Schema

    forward "/", Absinthe.Plug, schema: ServicesWeb.Schema
  end
end

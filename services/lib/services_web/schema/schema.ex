defmodule ServicesWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Schema.Notation

  object :notification do
    field(:channel, non_null(:string))
    field(:from, non_null(:string))
    field(:message, non_null(:string))
  end

  query do
    field :default, non_null(:string) do
      resolve(fn _, _, _ ->
        {:ok, "Default Query"}
      end)
    end
  end

  mutation do
    field :send_notification, non_null(:notification) do
      arg(:channel, non_null(:string))
      arg(:from, non_null(:string))
      arg(:message, non_null(:string))

      resolve(fn _, args, _ ->
        {:ok, %{channel: args.channel, from: args.from, message: args.message}}
      end)
    end
  end

  subscription do
    field :notification_received, non_null(:notification) do
      arg(:channel, non_null(:string))

      config(fn args, _ ->
        {:ok, topic: args.channel}
      end)

      trigger(:send_notification,
        topic: fn notification ->
          notification.channel
        end
      )

      resolve(fn notification, _, _ ->
        {:ok, notification}
      end)
    end
  end
end

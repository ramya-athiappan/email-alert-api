Rails.application.routes.draw do
  scope format: false, defaults: { format: :json } do
    root "welcome#index"
    resources :subscriber_lists, path: "subscriber-lists", only: %i[create]
    get "/subscriber-lists", to: "subscriber_lists#show"
    get "/subscribables/:slug", to: "subscribables#show"

    resources :notifications, only: %i[create index show]
    resources :status_updates, path: "status-updates", only: %i[create]
    resources :subscriptions, only: %i[create show update]

    patch "/subscribers/:id", to: "subscribers#change_address"
    delete "/subscribers/:id", to: "unsubscribe#unsubscribe_all"
    get "/subscribers/:id/subscriptions", to: "subscribers#subscriptions"

    get "/healthcheck", to: "healthcheck#check"

    post "/unsubscribe/:id", to: "unsubscribe#unsubscribe"
  end
end

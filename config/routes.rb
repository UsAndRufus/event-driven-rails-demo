Rails.application.routes.draw do
  resources :articles do
    member do
      # Should be post
      get :publish
    end
  end

  mount RailsEventStore::Browser => '/res' if Rails.env.development?
end

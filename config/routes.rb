require 'sidekiq/web'
Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  root 'auth#login'

  resources :feeds do
    get 'page/:page', action: :show, on: :member
    collection do
      match 'discover', via: :post
      match 'update_feed_group', via: :post
    end

    resources :feed_items, only: [:show], as: :items do
      member do
        get 'mark/read' => 'feed_items#mark_read'
        get 'mark/unread' => 'feed_items#mark_unread'
        get 'mark/saved' => 'feed_items#mark_saved'
        get 'mark/unsaved' => 'feed_items#mark_unsaved'
      end
    end
  end
  resources :groups, except: [:new]

  match 'setup' => 'setup#setup', via: [:get, :post], as: :setup

  match 'login' => 'auth#login', via: [:get, :post], as: :login
  delete 'login' => 'auth#logout', as: :logout


  # Fever API Endpoint
  get   '/fever' => 'fever#fever'
  post  '/fever' => 'fever#fever'
end

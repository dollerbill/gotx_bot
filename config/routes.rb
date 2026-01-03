# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'current_winners', to: 'games#current'
    end
  end

  get 'current_nominations', to: 'nominations#current_nominations'
  get 'previous_finishers', to: 'users#previous_finishers'
  resources :nominations do
    resources :completions, only: [:index]
    collection do
      get :winners
    end
    member do
      patch :select_winner
    end
  end
  resources :games do
    collection do
      post :create_weekly_retrobit
      post :create_monthly_rpg
    end
  end
  resources :themes

  # GotY management
  resources :goty, only: %i[show create] do
    collection do
      get :eligible_games_for_year
    end
    member do
      get :eligible_games
      get :eligible_gotw_games
      post :add_nomination
      post :add_gotwoty_nomination
    end
  end
  resources :users do
    member do
      post :redeem_points
    end
  end
  resources :streaks, only: %i[index show]
  resources :completions, only: %i[create destroy update]
  post 'create_message', to: 'messenger#create'
  root 'home#index'
end

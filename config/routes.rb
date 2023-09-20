# frozen_string_literal: true

Rails.application.routes.draw do
  get 'current_nominations', to: 'nominations#current_nominations'
  get 'previous_finishers', to: 'users#previous_finishers'
  resources :nominations do
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
  resources :users do
    member do
      post :redeem_points
    end
  end
  root 'home#index'
end

# frozen_string_literal: true

Rails.application.routes.draw do
  get 'nominations/new_rpg', to: 'nominations#new_rpg', as: 'new_rpg_nomination'
  get 'nominations/new_retro', to: 'nominations#new_retro', as: 'new_retro_nomination'
  get 'nominations/new_gotm', to: 'nominations#new_gotm', as: 'new_gotm_nomination'
  get 'current_nominations', to: 'nominations#current_nominations'
  resources :nominations do
    member do
      patch :select_winner
    end
  end
  resources :games do
    collection do
      post :create_weekly_retrobit
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

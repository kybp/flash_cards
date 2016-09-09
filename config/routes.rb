Rails.application.routes.draw do
  resources :flash_cards

  root 'flash_cards#index'
end

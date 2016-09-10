Rails.application.routes.draw do
  resources :flash_cards
  post '/flash_cards/:id/answer', to: 'flash_cards#answer'

  root 'flash_cards#index'
end

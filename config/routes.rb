Rails.application.routes.draw do
  root 'flash_cards#index'

  get  '/flash_cards/next',        to: 'flash_cards#next'
  post '/flash_cards/:id/answer', to: 'flash_cards#answer'

  resources :flash_cards
end

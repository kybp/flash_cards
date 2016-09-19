Rails.application.routes.draw do
  devise_for :users

  get  '/flash_cards/manage',     to: 'flash_cards#manage'
  get  '/flash_cards/next',       to: 'flash_cards#next'
  post '/flash_cards/:id/answer', to: 'flash_cards#answer'
  resources :flash_cards

  devise_scope :user do
    authenticated :user do
      root 'flash_cards#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new'
    end
  end
end

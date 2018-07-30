Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions' }
  devise_scope :user do
    get 'users/refresh_token', to: 'sessions#refresh_token'
  end

  resources :posts
end

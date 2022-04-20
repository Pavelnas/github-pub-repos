Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "github/repos#index"
  
  namespace :github do
    resources :repos, only: %i(index)
  end
end

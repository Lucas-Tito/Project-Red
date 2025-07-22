Rails.application.routes.draw do
  get "pages/login"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'pages#login' # Defines initial page

  # Route to main screen after login.
  get 'app', to: 'boards#index', as: :app_root

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :boards, only: [:create, :update, :destroy, :index]

  resources :lists do
    member do
      patch :move
    end
    # Tasks are nested under lists for creation (index, new, create)
    # Shallow nesting makes routes for individual tasks (show, edit, update, destroy) top-level (e.g., /tasks/:id)
    resources :tasks, shallow: true do
      member do
        patch :complete
        patch :snooze
      end
    end
  end

  resource :ai, only: [:show, :create]

  resources :boards, only: [:create, :update, :destroy, :index, :show] do
    resources :board_shared_links, only: [:create, :index], path: 'shared_links'
  end

  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

end

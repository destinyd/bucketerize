Rails.application.routes.draw do
  resources :projects
  #resources :folders
  resources :photos
  Bucketerize::Routing.mount '/', as: 'bucketerize'
  mount PlayAuth::Engine => '/auth', :as => :auth
  root 'photos#index'
end

Rails.application.routes.draw do
  resources :projects
  #resources :folders
  resources :photos
  mount Bucketerize::Engine => '/', :as => 'bucketerize'
  mount PlayAuth::Engine => '/auth', :as => :auth
  root 'photos#index'
end

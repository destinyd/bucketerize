Bucketerize::Engine.routes.draw do
  get '/buckets' => 'buckets#index', as: :buckets
  post '/buckets' => 'buckets#create'
  get '/bucketings' => 'bucketings#index', as: :bucketings
  post '/bucketings' => 'bucketings#create'
  delete '/bucketings' => 'bucketings#destroy'
end

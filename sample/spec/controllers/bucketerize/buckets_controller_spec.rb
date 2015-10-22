require 'rails_helper'

RSpec.describe Bucketerize::BucketsController, type: :controller do
  routes { Bucketerize::Engine.routes }

  before do
    @user = create(:user)
    @photo = create(:photo)
    session[:user_id] = @user.id.to_s
  end

  it 'GET index without resource_ids' do
    get :index, 
      {
        'bucket_type' => 'Folder', 
        'resource_type' => 'Photo'
      }

    expect(response.body).to include("get_buckets")
  end

  it 'GET index with resource_ids' do
    get :index, 
      {
        'bucket_type' => 'Folder', 
        'resource_type' => 'Photo', 
        'resource_ids' => [@photo.id]
      }

    expect(response.body).to include("get_resources_buckets")
  end

  it 'GET index after folder create' do
    @user.folders.create(name: 'test folder', desc: 'test desc')
    get :index, 
      {
        'bucket_type' => 'Folder', 
        'resource_type' => 'Photo', 
        'resource_ids' => [@photo.id]
      }

    expect(response.body).to include("get_resources_buckets")
  end

  it 'POST create' do
    post :create, 
      {
        'bucket_type' => 'Folder', 
        'name' => 'folder 1', 
        'desc' => 'desc 1'
      }

    expect(response.body).to include("create_bucket")
    expect(response.body).to include("\"name\":\"folder 1\"")
    expect(response.body).to include("\"desc\":\"desc 1\"")
  end

end

require 'rails_helper'

RSpec.describe Bucketerize::BucketingsController, type: :controller do
  routes { Bucketerize::Engine.routes }

  before do
    @user = create(:user)
    @photo = create(:photo)
    @folder = create(:folder, user: @user)
    session[:user_id] = @user.id.to_s
  end

  it 'GET index' do
    get :index, 
      {
        'bucket_type' => 'Folder', 
        'bucket_ids' => [@folder.id],
        'resource_type' => 'Photo',
        'resource_ids' => [@photo.id]
      }

    expect(response.body).to include("replace_buckets")
  end

  it 'POST create' do
    post :create, 
      {
        'bucket_type' => 'Folder', 
        'bucket_ids' => [@folder.id],
        'resource_type' => 'Photo',
        'resource_ids' => [@photo.id]
      }

    expect(response.body).to include("\"action\":\"add_to\"")
    expect(response.body).to include("\"resource_ids\":[\"#{@photo.id}\"]")
    expect(response.body).to include("\"buckets\":[{\"id\":\"#{@folder.id}\",\"name\":\"#{@folder.name}\",\"desc\":\"#{@folder.desc}\"}]")

    @folder.reload

    expect(@folder.photos).to include(@photo)
  end

  it 'DELETE destroy' do
    post :create, 
      {
        'bucket_type' => 'Folder', 
        'bucket_ids' => [@folder.id],
        'resource_type' => 'Photo',
        'resource_ids' => [@photo.id]
      }

    @folder.reload
    expect(@folder.photos).to include(@photo)

    delete :destroy, 
      {
        'bucket_type' => 'Folder', 
        'bucket_ids' => [@folder.id],
        'resource_type' => 'Photo',
        'resource_ids' => [@photo.id]
      }

    expect(response.body).to include("\"action\":\"remove_from\"")
    expect(response.body).to include("\"resource_ids\":[\"#{@photo.id}\"]")
    expect(response.body).to include("\"buckets\":[{\"id\":\"#{@folder.id}\",\"name\":\"#{@folder.name}\",\"desc\":\"#{@folder.desc}\"}]")

    @folder.reload
    expect(@folder.photos).not_to include(@photo)
  end
end


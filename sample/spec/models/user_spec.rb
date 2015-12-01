require 'rails_helper'

RSpec.describe User, type: :model do
  describe "举例" do
    it{
      expect(create(:user, name: 'tom').name).to eq("tom")
    }
  end

  it '#get_default_bucket' do
    class Ware
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource mode: :standard
    end

    @user = create(:user)
    @default_bucket = @user.get_default_bucket
    expect(@default_bucket).not_to eq(nil)
  end
end

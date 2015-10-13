require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe "Resource" do
    it "基础方法" do
      expect(create(:photo).respond_to?(:add_to_bucket)).to eq(true)
      expect(create(:photo).respond_to?(:add_to_buckets)).to eq(true)
      expect(create(:photo).respond_to?(:remove_from_bucket)).to eq(true)
      expect(create(:photo).respond_to?(:remove_from_buckets)).to eq(true)
    end
  end
end


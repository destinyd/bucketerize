require 'rails_helper'

RSpec.describe Folder, type: :model do
  describe "Bucket" do
    it "基础方法" do
      expect(create(:folder).respond_to?(:name)).to eq(true)
      expect(create(:folder).respond_to?(:desc)).to eq(true)
      expect(create(:folder).respond_to?(:user)).to eq(true)
      expect(create(:folder).respond_to?(:photos)).to eq(true)
      expect(create(:folder).respond_to?(:include_resource?)).to eq(true)
      expect(create(:folder).respond_to?(:include_resources?)).to eq(true)
      expect(create(:folder).respond_to?(:add_resource)).to eq(true)
      expect(create(:folder).respond_to?(:add_resources)).to eq(true)
      expect(create(:folder).respond_to?(:remove_resource)).to eq(true)
      expect(create(:folder).respond_to?(:remove_resources)).to eq(true)
    end
  end
end



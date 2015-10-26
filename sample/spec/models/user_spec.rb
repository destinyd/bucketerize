require 'rails_helper'

RSpec.describe User, type: :model do
  describe "举例" do
    it{
      expect(create(:user, name: 'tom').name).to eq("tom")
    }
  end
end

require 'rails_helper'

class Box
  include Bucketerize::Concerns::Bucket
  act_as_bucket collect: :book
end

describe 'bucket_resource_methods' do
  class Book
    include Bucketerize::Concerns::Resource
    act_as_bucket_resource into: :box
  end

  it do
    Book.new.respond_to?(:boxes).should == true
  end

  describe "two books and two boxes" do
    let(:book1){Book.new}
    let(:book2){Book.new}
    let(:box1){Box.new}
    let(:box2){Box.new}

    it do
      box1.include_resource?(book1).should == false
      book1.add_to_bucket(box1).should == true
      box1.include_resource?(book1).should == true

      book1.add_to_bucket(box1).should == false

      book1.add_to_bucket(box2).should == true
    end

    it "#add_to_buckets" do
      box1.include_resource?(book1).should == false
      book1.add_to_buckets([box1]).should == true
      box1.include_resource?(book1).should == true

      book1.add_to_buckets([box2]).should == true
      book1.add_to_buckets([box1, box2]).should == true
    end

    it "#remove_from_bucket" do
      book1.remove_from_bucket(box1).should == false
      book1.add_to_bucket(box1).should == true
      box1.include_resource?(book1).should == true
      book1.remove_from_bucket(box1).should == true
      box1.include_resource?(book1).should == false
    end

    it "#remove_from_buckets" do
      box1.include_resource?(book1).should == false
      book1.add_to_bucket(box1).should == true
      box1.include_resource?(book1).should == true

      book1.remove_from_buckets([box1]).should == true
      box1.include_resource?(book1).should == false
      book1.remove_from_buckets([ box2]).should == true

      # 没有则忽略
      book1.remove_from_buckets([box1, box2]).should == true
    end
  end
end


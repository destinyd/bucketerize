require 'rails_helper'

class Box
  include Bucketerize::Concerns::Bucket
  act_as_bucket collect: :book
end

describe 'bucket_resource_methods' do
  class Book
    include Bucketerize::Concerns::Resource
    act_as_bucket_resource mode: :multi, into: :box
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

  describe "修复同时多个经典收藏报错BUG" do
    class Book1
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource mode: :standard
    end

    class Book2
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource mode: :standard
    end

    before do
      current_user = create(:user)
      @bucket = current_user.get_default_bucket
      @book1 = Book1.create
    end

    it '#add_resource' do
      @bucket.add_resource @book1
      @bucket.reload
      @bucket.book1s.include? @book1

      @bucket.add_resource @book2
      @bucket.reload
      @bucket.book2s.include? @book2
    end
  end
end


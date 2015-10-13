require 'rails_helper'

class Folder
  include Bucketerize::Concerns::Bucket
  act_as_bucket collect: :book
end

describe 'bucket_resource_methods' do
  class Book
    include Bucketerize::Concerns::Resource
    act_as_bucket_resource into: :folder
  end

  it do
    Book.new.respond_to?(:folders).should == true
  end

  describe "two books and two folders" do
    let(:book1){Book.new}
    let(:book2){Book.new}
    let(:folder1){Folder.new}
    let(:folder2){Folder.new}

    it do
      folder1.include_resource?(book1).should == false
      book1.add_to_bucket(folder1).should == true
      folder1.include_resource?(book1).should == true

      book1.add_to_bucket(folder1).should == false

      book1.add_to_bucket(folder2).should == true
    end

    it "#add_to_buckets" do
      folder1.include_resource?(book1).should == false
      book1.add_to_buckets([folder1]).should == true
      folder1.include_resource?(book1).should == true

      book1.add_to_buckets([folder2]).should == true
      book1.add_to_buckets([folder1, folder2]).should == true
    end

    it "#remove_from_bucket" do
      book1.remove_from_bucket(folder1).should == false
      book1.add_to_bucket(folder1).should == true
      folder1.include_resource?(book1).should == true
      book1.remove_from_bucket(folder1).should == true
      folder1.include_resource?(book1).should == false
    end

    it "#remove_from_buckets" do
      folder1.include_resource?(book1).should == false
      book1.add_to_bucket(folder1).should == true
      folder1.include_resource?(book1).should == true

      book1.remove_from_buckets([folder1]).should == true
      folder1.include_resource?(book1).should == false
      book1.remove_from_buckets([ folder2]).should == true

      # 没有则忽略
      book1.remove_from_buckets([folder1, folder2]).should == true
    end
  end
end


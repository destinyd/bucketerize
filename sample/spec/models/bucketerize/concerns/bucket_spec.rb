require 'rails_helper'

describe 'bucket_methods' do
  describe "single collect" do
    class Book
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource into: :folder
    end

    class Folder
      include Bucketerize::Concerns::Bucket
      act_as_bucket collect: :book
    end

    let(:folder){Folder.create}

    it do
      folder.respond_to?(:books).should == true
    end

    it "#add_resource" do
      book = Book.create
      folder.books.should_not be_any
      folder.add_resource(book).should == true
      folder.books.should be_any
      # 重复添加返回 false
      folder.add_resource(book).should == false
    end

    it "#add_resources" do
      books = []
      book1 = Book.create
      books << book1
      books << Book.create
      folder.books.should_not be_any
      folder.add_resources(books).should == true
      folder.books.should be_any
      # 重复添加返回 false
      folder.add_resources([]).should == false
      folder.add_resources(Book.create).should == false
    end

    describe "add two book" do
      let(:book1) { Book.create}
      let(:book2) { Book.create}

      before do
        folder.add_resources [book1, book2]
      end

      it "#remove_resource" do
        folder.books.count.should == 2
        folder.books.should include(book1)
        folder.books.should include(book2)
        folder.remove_resource(book1).should == true
        folder.books.should_not include(book1)
        folder.include_resource?(book1).should == false
        folder.remove_resource(book2).should == true
        folder.books.should_not include(book2)
        folder.include_resource?(book2).should == false
        folder.books.count.should == 0
        folder.remove_resource(book2).should == false
      end

      it "#remove_resources wrong type" do
        folder.remove_resources(book1).should == false
        folder.remove_resources([]).should == false
        folder.remove_resources(nil).should == false
      end

      it "#remove_resources [book]" do
        folder.remove_resources([book1]).should == true
        folder.books.should_not include(book1)
        folder.remove_resources([book2]).should == true
        folder.books.should_not include(book2)

        # 没有则忽略
        folder.remove_resources([book2]).should == true
      end

      it "#remove_resources [books]" do
        folder.remove_resources([book1, book2]).should == true
        folder.books.should_not include(book1)
        folder.books.should_not include(book2)
        folder.include_resources?([book1, book2]).should == false

        # 没有则忽略
        folder.remove_resources([book1, book2]).should == true
      end
    end
  end

  describe "mutiple collect" do
    class Picture
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource into: :album
    end

    class Photo
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource into: :album
    end


    class Album
      include Bucketerize::Concerns::Bucket
      act_as_bucket collect: [:picture, :photo]
    end

    let(:album){Album.create}

    it do
      album.respond_to?(:pictures).should == true
    end

    it do
      album.respond_to?(:name).should == true
    end

    it do
      album.respond_to?(:desc).should == true
    end

    it "#add_resource" do
      picture = Picture.create
      album.pictures.should_not be_any
      album.add_resource(picture).should == true
      album.pictures.should be_any
      # 重复添加返回 false
      album.add_resource(picture).should == false

      photo = Photo.create
      album.photos.should_not be_any
      album.add_resource(photo).should == true
      album.photos.should be_any
      # 重复添加返回 false
      album.add_resource(photo).should == false
    end

    it "#add_resources" do
      resources = []
      picture = Picture.create
      photo = Photo.create
      resources << picture
      resources << photo
      album.add_resources(resources).should == true
      album.pictures.should be_any
      album.photos.should be_any
    end

    describe "add two type resources" do
      let(:picture) { Picture.create}
      let(:photo) { Photo.create}

      before do
        album.add_resources [picture, photo]
      end

      it "#remove_resource" do
        album.pictures.count.should == 1
        album.photos.count.should == 1
        album.pictures.should include(picture)
        album.photos.should include(photo)
        album.remove_resource(picture).should == true
        album.pictures.should_not include(picture)
        album.include_resource?(picture).should == false
        album.remove_resource(photo).should == true
        album.pictures.should_not include(photo)
        album.include_resource?(photo).should == false
        album.pictures.count.should == 0
        album.photos.count.should == 0
        album.remove_resource(picture).should == false
        album.remove_resource(photo).should == false
      end

      it "#remove_resources [picture]" do
        album.remove_resources([picture]).should == true
        album.pictures.should_not include(picture)

        # 没有则忽略
        album.remove_resources([picture]).should == true
      end

      it "#remove_resources [photo]" do
        album.remove_resources([photo]).should == true
        album.photos.should_not include(photo)

        # 没有则忽略
        album.remove_resources([photo]).should == true
      end

      it "#remove_resources [picture, photo]" do
        album.remove_resources([picture, photo]).should == true
        album.pictures.should_not include(picture)
        album.photos.should_not include(photo)
        album.include_resources?([picture, photo]).should == false

        # 没有则忽略
        album.remove_resources([picture, photo]).should == true
      end

      it "#remove_resources wrong type" do
        album.remove_resources(picture).should == false
        album.remove_resources(photo).should == false
        album.remove_resources([]).should == false
        album.remove_resources(nil).should == false
      end
    end
  end
end


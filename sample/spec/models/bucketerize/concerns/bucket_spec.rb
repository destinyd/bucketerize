require 'rails_helper'

describe 'bucket_methods' do
  describe "single collect" do
    class Book
      include Bucketerize::Concerns::Resource
      act_as_bucket_resource into: :favorite
    end

    class Favorite
      include Bucketerize::Concerns::Bucket
      act_as_bucket collect: :book
    end

    let(:favorite){Favorite.create}

    it do
      favorite.respond_to?(:books).should == true
    end

    it "#add_resource" do
      book = Book.create
      favorite.books.should_not be_any
      favorite.add_resource(book).should == true
      favorite.books.should be_any
      # 重复添加返回 false
      favorite.add_resource(book).should == false
    end

    it "#add_resources" do
      books = []
      book1 = Book.create
      books << book1
      books << Book.create
      favorite.books.should_not be_any
      favorite.add_resources(books).should == true
      favorite.books.should be_any
      # 重复添加返回 false
      favorite.add_resources([]).should == false
      favorite.add_resources(Book.create).should == false
    end

    describe "add two book" do
      let(:book1) { Book.create}
      let(:book2) { Book.create}

      before do
        favorite.add_resources [book1, book2]
      end

      it "#remove_resource" do
        favorite.books.count.should == 2
        favorite.books.should include(book1)
        favorite.books.should include(book2)
        favorite.remove_resource(book1).should == true
        favorite.books.should_not include(book1)
        favorite.include_resource?(book1).should == false
        favorite.remove_resource(book2).should == true
        favorite.books.should_not include(book2)
        favorite.include_resource?(book2).should == false
        favorite.books.count.should == 0
        favorite.remove_resource(book2).should == false
      end

      it "#remove_resources wrong type" do
        favorite.remove_resources(book1).should == false
        favorite.remove_resources([]).should == false
        favorite.remove_resources(nil).should == false
      end

      it "#remove_resources [book]" do
        favorite.remove_resources([book1]).should == true
        favorite.books.should_not include(book1)
        favorite.remove_resources([book2]).should == true
        favorite.books.should_not include(book2)

        # 没有则忽略
        favorite.remove_resources([book2]).should == true
      end

      it "#remove_resources [books]" do
        favorite.remove_resources([book1, book2]).should == true
        favorite.books.should_not include(book1)
        favorite.books.should_not include(book2)
        favorite.include_resources?([book1, book2]).should == false

        # 没有则忽略
        favorite.remove_resources([book1, book2]).should == true
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
  describe "special" do
    module KcCourses
      class Course
        include Bucketerize::Concerns::Resource
        act_as_bucket_resource into: :"kc_courses/fav"
      end

      class Chapter
        include Bucketerize::Concerns::Resource
        act_as_bucket_resource into: :"kc_courses/fav"
      end

      class Fav
        include Bucketerize::Concerns::Bucket
        act_as_bucket collect: [:"kc_courses/course", :"kc_courses/chapter"]
      end
    end

    before do
      @fav = KcCourses::Fav.create
      @course = KcCourses::Course.create
      @chapter = KcCourses::Chapter.create
    end

    it 'relationships' do
      expect(@fav.respond_to? :courses).to eq(true)
      expect(@fav.respond_to? :chapters).to eq(true)
    end

    it '#add_resource #include_resource #include_resources' do
      expect(@fav.include_resource?(@course)).to eq(false)
      expect(@fav.include_resources?([@course])).to eq(false)
      expect(@fav.add_resource(@course)).to eq(true)
      expect(@fav.include_resource?(@course)).to eq(true)
      expect(@fav.include_resources?([@course])).to eq(true)
    end

    it '#remove_resource' do
      @fav.add_resource(@course)
      expect(@fav.remove_resource(@course)).to eq(true)
      expect(@fav.include_resource?(@course)).to eq(false)
    end

    it '#remove_resources' do
      @fav.add_resource(@course)
      expect(@fav.remove_resources([@course])).to eq(true)
      expect(@fav.include_resource?(@course)).to eq(false)
    end

    it 'chapter' do
      expect(@fav.include_resources?([@chapter])).to eq(false)
      expect(@fav.add_resource(@chapter)).to eq(true)
      expect(@fav.include_resources?([@chapter])).to eq(true)
      expect(@fav.remove_resource(@chapter)).to eq(true)
      expect(@fav.include_resources?([@chapter])).to eq(false)
    end
  end
end

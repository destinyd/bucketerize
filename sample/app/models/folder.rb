class Folder
  include Bucketerize::Concerns::Bucket
  act_as_bucket collect: :photo
end

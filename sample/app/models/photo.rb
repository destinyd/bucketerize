class Photo
  include Bucketerize::Concerns::Resource
  act_as_bucket_resource into: :folder
  act_as_bucket_resource into: :'bucketerize/bucket'
end

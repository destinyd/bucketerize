class Photo
  include Bucketerize::Concerns::Resource
  act_as_bucket_resource mode: :multi, into: :folder
end

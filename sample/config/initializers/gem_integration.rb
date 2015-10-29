User.class_eval do
  has_many :folders
end

Bucketerize::Bucket.class_eval do
  act_as_bucket collect: :project
end

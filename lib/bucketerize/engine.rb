module Bucketerize
  class Engine < ::Rails::Engine
    isolate_namespace Bucketerize
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper

      User.class_eval do
        has_many :buckets, class_name: 'Bucketerize::Bucket', inverse_of: :user
      end
    end
  end
end

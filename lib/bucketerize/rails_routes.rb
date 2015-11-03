module Bucketerize
  class Routing
    # Bucketerize::Routing.mount "/file_part_upload", :as => 'file_part_upload'
    def self.mount(prefix, options)
      Bucketerize.set_mount_prefix prefix

      Rails.application.routes.draw do
        mount Bucketerize::Engine => prefix, :as => options[:as]
      end
    end
  end
end

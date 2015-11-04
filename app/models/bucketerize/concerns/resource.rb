module Bucketerize
  module Concerns
    module Resource
      extend ActiveSupport::Concern

      included do
        include Mongoid::Document
        include Mongoid::Timestamps

        cattr_accessor :into
        cattr_accessor :mode
      end

      module ClassMethods
        # act_as_bucket_resource into: :folder

        def act_as_bucket_resource(*fields, &block)
          options = fields.extract_options!
          self.into = options[:into]
          self.mode = options[:mode]

          case self.mode
          when :multi
            # 复合收藏
            case self.into.class.name
            when "Symbol", "String"
              self.into = self.into.to_s
            else
              raise "must be symbol or string"
            end
          when :standard
            # 经典收藏
            self.into = 'bucketerize/bucket' if self.into.blank?
            Bucketerize::Bucket.class_eval do
              act_as_bucket collect: name.underscore.split('/').last
            end
          else
            raise 'mode must be :multi or :standard'
          end

          has_and_belongs_to_many into.to_s.split('/').last.pluralize, class_name: into.camelize, inverse_of: self.name.underscore.split('/').last.pluralize.to_sym

          define_method :add_to_bucket do |bucket|
            singularize_name = bucket.class.name.underscore
            pluralize_name = singularize_name.split('/').last.pluralize
            return bucket.add_resource(self) if self.into == singularize_name
            false
          end

          define_method :add_to_buckets do |buckets|
            if buckets.class.name == "Array"
              buckets.each do |bucket|
                add_to_bucket(bucket)
              end
              return true
            end
            false
          end

          define_method :remove_from_bucket do |resource|
            return true if resource.class.name.underscore == self.into and resource.remove_resource(self)
            false
          end

          define_method :remove_from_buckets do |resources|
            if resources.class.name == "Array"
              resources.each do |resource|
                remove_from_bucket(resource)
              end
              return true
            end
            false
          end
        end
      end
    end
  end
end

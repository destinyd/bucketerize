module Bucketerize
  module Concerns
    module Bucket
      extend ActiveSupport::Concern

      included do
        include Mongoid::Document
        include Mongoid::Timestamps

        cattr_accessor :collect
      end

      module ClassMethods
        # 两种形式
        # act_as_bucket :collect => :photo
        # act_as_bucket :collect => [:book, :photo]
        def act_as_bucket(*fields, &block)
          options = fields.extract_options!

          self.collect ||= []
          case options[:collect].class.name
          when "Symbol", "String"
            self.collect += [options[:collect].to_s]
          when "Array"
            self.collect = options[:collect].map(&:to_s)
          else
            raise "must be array, string or symbol"
          end

          field :name, type: String
          field :desc, type: String

          belongs_to :user

          self.collect.each do |sym|
            has_and_belongs_to_many sym.to_s.split('/').last.pluralize, class_name: sym.to_s.camelize, inverse_of: self.name.underscore.split('/').last.pluralize.to_sym
          end

          define_method :get_pluralize_name do |singularize_name|
            singularize_name.split('/').last.pluralize
          end

          define_method :include_resource? do |resource|
            singularize_name = resource.class.name.underscore
            pluralize_name = get_pluralize_name(singularize_name)
            return true if self.collect.include?(singularize_name) and send(pluralize_name).include?(resource)
            false
          end

          define_method :include_resources? do |resources|
            if resources.class.name == "Array"
              return true if resources.map{|resource| include_resource?(resource)}.all?
            end
            false
          end

          define_method :add_resource do |resource|
            singularize_name = resource.class.name.underscore
            pluralize_name = get_pluralize_name(singularize_name)
            if self.collect.include?(singularize_name) and !include_resource?(resource)
              send(pluralize_name) << resource
              return true
            end
            false
          end

          define_method :add_resources do |resources|
            if resources.class.name == "Array"
              resources.compact!
              resources.uniq!
              if !resources.blank? and !include_resources?(resources)
                resources.each do |resource|
                  add_resource(resource)
                end
                return true
              end
            end
            false
          end

          define_method :remove_resource do |resource|
            if include_resource?(resource)
              singularize_name = resource.class.name.underscore
              pluralize_name = get_pluralize_name(singularize_name)
              if self.collect.include?(singularize_name) and send(pluralize_name).include?(resource)
                send(pluralize_name).delete resource
                return true
              end
            end
            false
          end

          define_method :remove_resources do |resources|
            if resources.class.name == "Array"
              resources.compact!
              resources.uniq!
              if !resources.blank?
                resources.each do |resource|
                  remove_resource(resource)
                end
                return true
              end
            end
            false
          end
        end
      end
    end
  end
end

module Bucketerize
  class BucketingsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    #before_filter :authenticate_user!

    def index
      #begin 
        bucket_ids = params[:bucket_ids]
        resource_ids = params[:resource_ids]

        @buckets = bucket_start.find bucket_ids
        @resources = resource_start.find resource_ids
        render json: {
          action: "replace_buckets",
          result: {
            resource_ids: resource_ids,
            buckets: @buckets.map do |bucket|
              {
                id: bucket.id.to_s,
                name: bucket.name,
                desc: bucket.desc
              }
            end
          }
        }
      #rescue
        #render json: {error: "unknowns"}, status: 500
      #end
    end

    def create
      #begin
        bucket_ids = params[:bucket_ids]
        resource_ids = params[:resource_ids]

        @buckets = bucket_start.find bucket_ids
        @resources = resource_start.find resource_ids
        @resources.each do |resource|
          resource.add_to_buckets @buckets
        end
        render json: {
          action: "add_to",
          result: {
            resource_ids: resource_ids,
            buckets: @buckets.map do |bucket|
              {
                id: bucket.id.to_s,
                name: bucket.name,
                desc: bucket.desc
              }
            end
          }
        }
      #rescue
        #render json: {error: "unknowns"}, status: 500
      #end
    end

    def destroy
      #begin 
        bucket_ids = params[:bucket_ids]
        resource_ids = params[:resource_ids]

        @buckets = bucket_start.find bucket_ids
        @resources = resource_start.find resource_ids
        @resources.each do |resource|
          resource.remove_from_buckets @buckets
        end
        render json: {
          action: "remove_from",
          result: {
            resource_ids: resource_ids,
            buckets: @buckets.map do |bucket|
              {
                id: bucket.id.to_s,
                name: bucket.name,
                desc: bucket.desc
              }
            end
          }
        }
      #rescue
        #render json: {error: "unknowns"}, status: 500
      #end
    end

    protected
    def get_bucket_type
      params[:bucket_type]
    end

    def bucket_start
      current_user.send(get_bucket_type.underscore.split('/').last.pluralize)
    end

    def resource_start
      params[:resource_type].constantize
    end
  end
end

module Bucketerize
  class BucketsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    #before_filter :authenticate_user!

    def index
      #begin 
        if params[:resource_ids].blank?
          buckets = collection
          render json: {
            action: "get_buckets",
            result: buckets.map{ |bucket|
              {
                id: bucket.id.to_s,
                name: bucket.name,
                desc: bucket.desc
              }
            }
          }
        else
          resource_ids =  params[:resource_ids]
          if params[:bucket_type] == 'Bucket'
            # 创建默认Bucket
            current_user.get_default_bucket
            buckets = current_user.buckets
          else
            buckets = collection
          end
          result = {
            action: "get_resources_buckets",
            result: resource_ids.map do |resource_id|
              {
                id: resource_id, 
                buckets:
                buckets.map do |bucket|
                  {
                    id: bucket.id.to_s,
                    name: bucket.name,
                    desc: bucket.desc,
                    added: get_resource(resource_id) ? bucket.include_resource?(get_resource(resource_id)) : false
                  }
                end
              }
            end
          }

          render json: result
        end
      #rescue
        #render json: {error: "unknowns"}, status: 500
      #end
    end

    def create
      #begin 
        name = params[:name]
        desc = params[:desc]
        @bucket = bucket_start.create name: name, desc: desc
        render json: {
          action: "create_bucket",
          result: {
            id: @bucket.id.to_s,
            name: @bucket.name,
            desc: @bucket.desc
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

    def collection
      bucket_start.all
    end

    def get_resource(resource_id)
      return nil if params[:resource_type].blank?
      params[:resource_type].constantize.find resource_id
    end
  end
end

class @BucketerizeHook
  constructor: (@api) ->
    console.log 'bucketerize hook constructor'

  el_click: (el) ->
    console.log 'bucketerize hook el click'

  get_all_buckets_success: (buckets) =>
    console.log 'bucketerize hook get all buckets success'

  get_resources_buckets_success: (data) =>
    console.log 'bucketerize hook get resources buckets  success'

  create_bucket_success: (bucket) =>
    console.log 'bucketerize hook create bucket success'

  add_to_success: (resource_ids, buckets) =>
    console.log 'bucketerize hook add to success'

  replace_buckets_success: (resource_ids, buckets) =>
    console.log 'bucketerize hook replace buckets success'

  remove_from_success: (bucket) ->
    console.log 'bucketerize hook remove_from_success'

  error: (error) ->
    console.log 'error'
    console.log error

  assigned_resource_ids: ->
    console.log 'assigned_resource_ids'
    resource_ids = []

  assigned_bucket_ids: ->
    console.log 'assigned_bucket_ids'
    bucket_ids = []

class @Bucketerize
  constructor: (@configs)->
    @_init()

  _default_configs:
    path_fix: ""
    bucket_type: "Bucket"
    resource_type: "Shot"
    hook_class: BucketerizeHook

  _init: ->
    for key, val of @_default_configs
      @configs[key] ||= val

    @path_fix = @configs["path_fix"]
    @buckets_path = @path_fix + "/buckets"
    @bucketings_path = @path_fix + "/bucketings"

    @$el = jQuery(@configs["selector"])

    @resource_type = @configs['resource_type']
    @bucket_type = @configs["bucket_type"]
    @hook = new @configs["hook_class"](@)

  get_all_buckets: () ->
    console.log @
    resource_ids = @hook.assigned_resource_ids()
    if !@bucket_type or !@resource_type
      return @hook.error {error: "params blank"}

    @_get_buckets()

  get_resources_buckets: () ->
    if !@bucket_type or !@resource_type
      return @hook.error {error: "params blank"}

    @_get_buckets(@hook.assigned_resource_ids())

  _get_buckets: (resource_ids) ->
    console.log '_get_buckets'
    jQuery.ajax
      url: @buckets_path
      method: "GET"
      data:
        bucket_type: @bucket_type
        resource_type: @resource_type
        "resource_ids[]": resource_ids
      success: (res) =>
        console.log "buckets success"
        console.log res
        if res['error']
          @hook.error(res.error)
        else
          if res['action'] == 'get_buckets'
            @hook.get_all_buckets_success(res.result)
          else if res['action'] == 'get_resources_buckets'
            @hook.get_resources_buckets_success(res.result)



  create_bucket: (bucket_name, bucket_desc) ->
    console.log 'create bucket'
    @_create_bucket(@bucket_type, bucket_name, bucket_desc)

  add_to: () ->
    console.log 'add to bucket'
    console.log @hook.assigned_bucket_ids()
    @_add_to_bucket(@resource_type, @hook.assigned_resource_ids(), @bucket_type, @hook.assigned_bucket_ids())

  remove_from: () ->
    console.log 'remove from bucket'
    @_remove_from_bucket(@resource_type, @hook.assigned_resource_ids(), @bucket_type, @hook.assigned_bucket_ids())

  replace_buckets: () ->
    console.log 'replace_buckets'
    @_replace_buckets(@resource_type, @hook.assigned_resource_ids(), @bucket_type, @hook.assigned_bucket_ids())

  _create_bucket: (bucket_type, name, desc) ->
    jQuery.ajax
      url: @buckets_path
      method: "POST"
      data: 
        bucket_type: bucket_type
        name: name
        desc: desc
      success: (res) =>
        console.log "create bucket success"
        console.log res
        if res['error']
          @hook.error(res.error)
        else
          console.log res.result
          @hook.create_bucket_success(res.result)

  _add_to_bucket: (resource_type, resource_ids, bucket_type, bucket_ids) ->
    jQuery.ajax
      url: @bucketings_path
      method: "POST"
      data:
        resource_type: resource_type
        "resource_ids[]": resource_ids
        bucket_type: bucket_type
        "bucket_ids[]": bucket_ids
      success: (res) =>
        console.log "add to bucket success"
        console.log res
        if res['error']
          @hook.error(res.error)
        else
          console.log res.result.resource_ids
          console.log res.result.buckets
          @hook.add_to_success(res.result.resource_ids, res.result.buckets)

  _remove_from_bucket: (resource_type, resource_ids, bucket_type, bucket_ids) ->
    jQuery.ajax
      url: @bucketings_path
      method: "DELETE"
      data:
        resource_type: resource_type
        "resource_ids[]": resource_ids
        bucket_type: bucket_type
        "bucket_ids[]": bucket_ids
      success: (res) =>
        console.log "add to bucket success"
        console.log res
        if res['error']
          @hook.error(res.error)
        else
          console.log res.result.resource_ids
          console.log res.result.buckets
          @hook.remove_from_success(res.result.resource_ids, res.result.buckets)


  _replace_buckets: (resource_type, resource_ids, bucket_type, bucket_ids) ->
    jQuery.ajax
      url: @bucketings_path
      method: "GET"
      data:
        resource_type: resource_type
        "resource_ids[]": resource_ids
        bucket_type: bucket_type
        "bucket_ids[]": bucket_ids
      success: (res) =>
        console.log "replace buckets success"
        console.log res
        if res['error']
          @hook.error(res.error)
        else
          console.log res.result.resource_ids
          console.log res.result.buckets
          @hook.replace_buckets_success(res.result.resource_ids, res.result.buckets)


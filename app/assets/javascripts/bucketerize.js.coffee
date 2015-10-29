class @ModalBucketerizeHook
  constructor: (@api) ->
    console.log 'ModalBucketerizeHook'
    @append_modal()
    @$modal_buckets = jQuery('#modal-buckets')
    @$el = jQuery("[data-rel=bucketerize]")
    @resource_ids = [@$el.data('resource-id')]
    @_init()

  _init: () ->
    @bucket_ids = []
    @$el.on 'click', =>
      @$modal_buckets.modal('show')

    # 创建按钮点击
    @$modal_buckets.find('.new').click () =>
      console.log 'click new'
      @modal_new_bucket.modal('show')

    @modal_new_bucket = jQuery('#modal-new-bucket')

    @modal_new_bucket.find('.create').click () =>
      console.log 'create'
      name = @modal_new_bucket.find('.name').val()
      desc = @modal_new_bucket.find('.desc').val()
      console.log name
      console.log desc
      @api.create_bucket(name, desc)

    # 点击事件绑定：添加、移除到bucket
    that = this
    @$modal_buckets.on 'click', '.buckets a.list-group-item', ->
      if $(this).hasClass('active')
        bucket_id = $(this).data('id')
        that.bucket_ids = [bucket_id]
        that.api.remove_from()
      else
        bucket_id = $(this).data('id')
        that.bucket_ids = [bucket_id]
        that.api.add_to() # that.api.resource_type, that.api.resource_id, bucket_type, bucket_id)

  el_click: (el) ->
    console.log 'hook el click'
    @api.get_all_buckets()
    @$modal_buckets.modal('show')

  get_resources_buckets_success: (data) =>
    console.log 'hook get resources buckets success'
    console.log data
    str = ''
    that = this
    for obj in data
      jQuery.each obj.buckets, ->
        bucket = this
        str += that._str_bucket(bucket.id, bucket.name, bucket.added)
    @$modal_buckets.find('.buckets').html(str)

  create_bucket_success: (bucket) =>
    console.log 'hook create bucket success'
    that = this
    str = @_str_bucket(bucket.id, bucket.name, false)
    @$modal_buckets.find('.buckets').append str

    @modal_new_bucket.find('.name').val('')
    @modal_new_bucket.find('.desc').val('')
    @modal_new_bucket.modal('hide')

  add_to_success: (resource_ids, buckets) =>
    that = this
    jQuery.each buckets, ->
      bucket = this
      that.$modal_buckets.find("[data-id=#{bucket.id}]").addClass('active')

  remove_from_success:  (resource_ids, buckets) =>
    console.log 'remove_from_success'
    that = this
    jQuery.each buckets, ->
      bucket = this
      that.$modal_buckets.find("[data-id=#{bucket.id}]").removeClass('active')

  replace_buckets_success: (resource_ids, buckets) =>
    console.log 'hook replace buckets success'

    that = this
    jQuery.each buckets, ->
      bucket = this
      that.$modal_buckets.find("[data-id=#{bucket.id}]").removeClass('active')


  assigned_resource_ids: () ->
    #["557f9857636865734e000002"] #, "557f985b636865734e000003"]
    @resource_ids

  assigned_bucket_ids: ->
    @bucket_ids

  _str_bucket: (id, name, added) ->
    "<a class=\"list-group-item #{if added then "active" else ""}\" data-id=\"#{id}\" id=\"bucket_#{id}\"><strong>#{name}</strong><span class=\"bucket-meta\">更新时间</span></a>"

  append_modal: ->
    jQuery('body').append @modal_template()
    
  modal_template: ->
    """
            <div class='modal fade' id='modal-buckets'>
              <div class='modal-dialog'>
                <div class='modal-content'>
                  <div class='modal-header'>
                    <button aria-label='Close' class='close' data-dismiss='modal' type='button'>
                      <span aria-hidden='true'>&times;</span>
                    </button>
                    <h4 class='modal-title'>添加 #{@api.resource_type} 至 #{@api.bucket_type}</h4>
                  </div>
                  <div class='modal-body'>
                    <div class='list-group buckets'></div>
                    <ol class='group'></ol>
                  </div>
                  <div class='modal-footer'>
                    <button class='btn btn-default' data-dismiss='modal' type='button'>Done</button>
                    <a class='new btn btn-primary' href='javascript:;'>+ 新建#{@api.bucket_type}</a>
                  </div>
                </div>
              </div>
            </div>
            <div class='modal fade' id='modal-new-bucket'>
              <div class='modal-dialog'>
                <div class='modal-content'>
                  <div class='modal-header'>
                    <button aria-label='Close' class='close' data-dismiss='modal' type='button'>
                      <span aria-hidden='true'>&times;</span>
                    </button>
                    <h4 class='modal-title'>新建#{@api.bucket_type}</h4>
                  </div>
                  <div class='modal-body'>
                    <div class='form-group'>
                      <input class='form-control name' placeholder='名称' type='text'>
                    </div>
                    <div class='form-group'>
                      <input class='form-control desc' placeholder='描述' type='text'>
                    </div>
                  </div>
                  <div class='modal-footer'>
                    <button class='btn btn-default' data-dismiss='modal' type='button'>取消</button>
                    <a class='create btn btn-primary' href='javascript:;'>提交</a>
                  </div>
                </div>
              </div>
            </div>
      """

class @StandardBucketerizeHook
  constructor: (@api) ->
    console.log 'StandardBucketerizeHook'
    @resource_ids = [@api.$el.data('resource-id')]
    @_init()

  _init: () ->
    @bucket_ids = []
    that = this
    @api.$el.on 'click', ->
      $this = jQuery(this)
      if $this.hasClass('liked')
        that.api.remove_from()
      else
        that.api.add_to()

  get_resources_buckets_success: (data) =>
    that = this
    jQuery.each data, (index) ->
      resource_id = this['id']
      jQuery.each this['buckets'], (index1) ->
        if this['added'] and this['name'] == '默认'
          jQuery.each that.api.$el, ->
            $this = jQuery(this)
            $this.removeClass('btn-info').addClass('btn-default').addClass('liked').html('已收藏') if $this.data('resource-id') == resource_id
        else
          jQuery.each that.api.$el, ->
            $this = jQuery(this)
            $this.addClass('btn-info').removeClass('btn-default').html('收藏') if $this.data('resource-id') == resource_id

  remove_from_success:  (resource_ids, buckets) =>
    resource_id = resource_ids[0]
    @api.$el.each (index)->
      $this = jQuery(this)
      $this.removeClass('btn-default').addClass('btn-info').removeClass('liked').html('收藏') if $this.data('resource-id') == resource_id

  add_to_success: (resource_ids, buckets) =>
    resource_id = resource_ids[0]
    @api.$el.each (index)->
      $this = jQuery(this)
      $this.addClass('btn-default').addClass('liked').removeClass('btn-info').html('已收藏') if $this.data('resource-id') == resource_id

  assigned_resource_ids: () ->
    @resource_ids

  assigned_bucket_ids: ->
    @bucket_ids

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
    mode: 'custom'

  _init: ->
    for key, val of @_default_configs
      @configs[key] ||= val

    @path_fix = @configs["path_fix"]
    @buckets_path = @path_fix + "/buckets"
    @bucketings_path = @path_fix + "/bucketings"

    @$el = jQuery(@configs["selector"])

    @resource_type = @configs['resource_type']
    @bucket_type = @configs["bucket_type"]

    if @configs['mode'] == 'modal'
      @configs['hook_class'] = ModalBucketerizeHook if !@configs['hook_class']
    else if @configs['mode'] == 'standard'
      @configs['hook_class'] = StandardBucketerizeHook if !@configs['hook_class']
    else
      @configs['hook_class'] = BucketerizeHook

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


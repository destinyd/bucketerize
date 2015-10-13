# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class FolderHook extends BucketerizeHook
  constructor: (@api) ->
    @$modal_folders = jQuery('#modal-folders')
    @$el = jQuery("[data-rel=bucketerize]")
    @resource_ids = [@$el.data('resource-id')]
    @_init()

  _init: () ->
    @bucket_ids = []
    @$el.on 'click', =>
      @$modal_folders.modal('show')

    # 创建按钮点击
    @$modal_folders.find('.new').click () => 
      console.log 'click new'
      @modal_new_folder.modal('show')

    @modal_new_folder = jQuery('#modal-new-folder')

    @modal_new_folder.find('.create').click () =>
      console.log 'create'
      name = @modal_new_folder.find('.name').val()
      desc = @modal_new_folder.find('.desc').val()
      console.log name
      console.log desc
      @api.create_bucket(name, desc)

    # li点击事件绑定：添加、移除到folder
    that = this
    @$modal_folders.on 'click', '.buckets li.group', ->
      console.log 'click li'
      if $(this).hasClass('unbucketed')
        bucket_id = $(this).data('id')
        that.bucket_ids = [bucket_id]
        that.api.add_to() # that.api.resource_type, that.api.resource_id, bucket_type, bucket_id)
      else
        bucket_id = $(this).data('id')
        that.bucket_ids = [bucket_id]
        that.api.remove_from()
    
  el_click: (el) ->
    console.log 'hook el click'
    @api.get_all_buckets()
    # todo
    @$modal_folders.modal('show')

  get_resources_buckets_success: (data) =>
    console.log 'hook get resources buckets success'
    console.log data
    str = ''
    that = this
    for obj in data
      jQuery.each obj.buckets, ->
        bucket = this
        str += that._str_bucket(bucket.id, bucket.name, bucket.added)
    @$modal_folders.find('.buckets').html(str)

  create_bucket_success: (bucket) =>
    console.log 'hook create bucket success'
    that = this
    str = @_str_bucket(bucket.id, bucket.name, false)
    @$modal_folders.find('.buckets').append str

    @modal_new_folder.find('.name').val('')
    @modal_new_folder.find('.desc').val('')
    @modal_new_folder.modal('hide')

  add_to_success: (resource_ids, buckets) =>
    that = this
    jQuery.each buckets, ->
      bucket = this
      that.$modal_folders.find("[data-id=#{bucket.id}]").removeClass('unbucketed').addClass('bucketed')

  remove_from_success:  (resource_ids, buckets) =>
    console.log 'remove_from_success'
    that = this
    jQuery.each buckets, ->
      bucket = this
      that.$modal_folders.find("[data-id=#{bucket.id}]").removeClass('bucketed').addClass('unbucketed')

  replace_buckets_success: (resource_ids, buckets) =>
    console.log 'hook replace buckets success'

    that = this
    jQuery.each buckets, ->
      bucket = this
      that.$modal_folders.find("[data-id=#{bucket.id}]").removeClass('bucketed').addClass('unbucketed')


  assigned_resource_ids: () ->
    #["557f9857636865734e000002"] #, "557f985b636865734e000003"]
    @resource_ids

  assigned_bucket_ids: ->
    @bucket_ids

  _str_bucket: (id, name, added) ->
    "<li class=\"group #{if !added then "un" else ""}bucketed\" data-id=\"#{id}\" id=\"bucket_#{id}\"><a href=\"javascript:;\"><strong>#{name}</strong><!--<span class=\"bucket-meta\">1 photos</span>--><span class=\"bucket-meta\">更新时间</span></a></li>"


jQuery(document).on 'ready page:load', ->
  configs = 
    bucket_type: "Folder"
    resource_type: "Photo"
    hook_class: FolderHook

  window.bucketerize = new Bucketerize(configs)
  window.bucketerize.get_resources_buckets()

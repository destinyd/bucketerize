# Bucketerize

这是一个通用收藏夹 Gem ， 为 Rails Engine 形式。  
方便您给您的项目添加收藏功能。

暂时只支持 mongoid

## Installation

添加 bucketerize 到你项目的 Gemfile:

```ruby
gem 'bucketerize', git: 'https://github.com/mindpin/bucketerize.git'
```

然后运行:

    $ bundle


## 用例
### 模型层
首先您得设置至少一个收藏夹模型, 例如 Folder
```ruby
class Folder
  include Bucketerize::Concerns::Bucket
  act_as_bucket collect: :photo
end
```

然后还得给被收藏的模型，添加一些引用
```ruby
class Photo
  include Bucketerize::Concerns::Resource
  act_as_bucket_resource into: :folder
end
```

以上例子为的意思为，收藏夹模型叫做 Folder(文件夹), 收藏内容为 Photo(图片)

### 路由
```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Bucketerize::Engine => '/', :as => 'bucketerize'
end
```

### Views
```haml
\app/views/photos/show.html.haml
%a.add_to_folder.btn.btn-default{href: 'javascript:;', data: {rel: "bucketerize", resource: {type: 'photo', id: @photo.id}}} 添加到Folder

#modal-folders.modal.fade
  .modal-dialog
    .modal-content
      .modal-header
        %button.close{:type => "button", :data => {:dismiss => "modal"}, :aria => {:label => "Close"}}
          %span{:aria => {:hidden => "true"}} &times;
        %h4.modal-title Add this photo to a folder

      .modal-body
        %ol.buckets.group

      .modal-footer
        %button.btn.btn-default{:type => "button", :data => {:dismiss => "modal"}} Done
        %a.new.btn.btn-primary{href: 'javascript:;'} + Create a new folder


#modal-new-folder.modal.fade
  .modal-dialog
    .modal-content
      .modal-header
        %button.close{:type => "button", :data => {:dismiss => "modal"}, :aria => {:label => "Close"}}
          %span{:aria => {:hidden => "true"}} &times;
        %h4.modal-title 新建Folder

      .modal-body
        .form-group
          %input.form-control.name{type: "text", placeholder: "名称"}
        .form-group
          %input.form-control.desc{type: "text", placeholder: "描述"}

      .modal-footer
        %button.btn.btn-default{:type => "button", :data => {:dismiss => "modal"}} 取消
        %a.create.btn.btn-primary{href: 'javascript:;'} 提交
```

### Assets
添加 bucketerize 引用
```javascript
// app/assets/javascripts/application.js
//= require bucketerize
```

Hook(应该叫Progress)各回调
```coffeescript
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
```

编写 Hook (应该叫Progress)，以下是 sample 具体实例
```coffeescript
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

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mindpin/bucketerize. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


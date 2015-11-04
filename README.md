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


## 交互模式收藏

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
  act_as_bucket_resource mode: :multi, into: :folder
end
```

以上例子为的意思为，收藏夹模型叫做 Folder(文件夹), 收藏内容为 Photo(图片), 指定模式为multi(交互模式收藏)

最后还需要给 User 加上相关关系(收藏夹，本文为Folder)
```ruby
class User
  has_many :folders
end
```

### 路由
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # sample路径为'/',也可以改为其他的路径，例如'/bucketerize'
  Bucketerize::Routing.mount '/', as: 'bucketerize'
end
```

### Views
配置写在DOM内，并可以设置未添加、已添加时候显示的内容。
**app/views/photos/show.html.haml**
```haml
.bucketerize{data: {rel: "bucketerize", bucketerize: {mode: 'multi', resource_type: 'Photo', resource_id: @photo.id, bucket_type: 'Folder'}}}
  .unhas
    %button.btn.btn-info 添加到Folder
  .has
    %button.btn.btn-default 已添加到Folder
```

### Assets
添加 bucketerize 引用
```coffeescript
# app/assets/javascripts/application.js
#= require bucketerize

jQuery(document).on 'ready page:load', ->
  configs = 
    selector: '.bucketerize'

  window.bucketerize = new Bucketerize(configs)
```

## 经典模式收藏

### 模型层
在需要经典模式收藏的模型里，进行设置
```ruby
class Project
  include Bucketerize::Concerns::Resource
  act_as_bucket_resource mode: :standard
end
```

以上例子为的意思为，给Project(工程), 添加经典模式收藏功能(standard)。

最后还需要给 经典模式收藏模型 加上相关关系
```ruby
Bucketerize::Bucket.class_eval do
  act_as_bucket collect: :project
end
```

### 路由
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # sample路径为'/',也可以改为其他的路径，例如'/bucketerize'
  Bucketerize::Routing.mount '/', as: 'bucketerize'
end
```

### Views
配置写在DOM内，并可以设置未添加、已添加时候显示的内容。
**app/views/photos/show.html.haml**
```haml
.bucketerize{data: {rel: "bucketerize", bucketerize: {mode: 'standard', resource_type: 'Project', resource_id: @project.id}}}
  .unhas
    %button.btn.btn-default 收藏
  .has
    %button.btn.btn-info 已收藏

```

### Assets
添加 bucketerize 引用
```coffeescript
# app/assets/javascripts/application.js
#= require bucketerize

jQuery(document).on 'ready page:load', ->
  configs = 
    selector: '.bucketerize'

  window.bucketerize = new Bucketerize(configs)
```


-----------

改版后暂时未完善。

## Hook(应该叫Progress)各回调
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mindpin/bucketerize. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


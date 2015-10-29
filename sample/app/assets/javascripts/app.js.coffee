jQuery(document).on 'ready page:load', ->
  configs = 
    bucket_type: "Folder"
    resource_type: "Photo"
    mode: 'modal'

  window.bucketerize = new Bucketerize(configs)
  window.bucketerize.get_resources_buckets()

  standard_configs = 
    selector: '.like[data-rel=like]'
    resource_type: "Project"
    mode: 'standard'
  window.standard = new Bucketerize(standard_configs)
  window.standard.get_resources_buckets()

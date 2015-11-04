jQuery(document).on 'ready page:load', ->
  configs = 
    selector: '.bucketerize'

  window.bucketerize = new Bucketerize(configs)

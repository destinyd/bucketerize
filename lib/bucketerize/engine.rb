module Bucketerize
  class Engine < ::Rails::Engine
    isolate_namespace Bucketerize
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper
    end
  end
end

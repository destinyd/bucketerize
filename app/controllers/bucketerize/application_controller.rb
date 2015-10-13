module Bucketerize
  class ApplicationController < ActionController::Base
    layout "bucketerize/application"

    if defined? ::PlayAuth
      include ::PlayAuth::SessionsHelper
    end
  end
end

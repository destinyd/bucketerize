module Bucketerize
  class << self
    attr_accessor :root, :base_path

    def config(&block)
      # 读取配置
      Bucketerize::Config.config(&block)

      # 根据 mode 加载不同的模块
      Bucketerize::ModuleLoader.load_by_mode!
    end

    def bucketerize_config
      self.instance_variable_get(:@bucketerize_config) || {}
    end

    def set_mount_prefix(mount_prefix)
      config = Bucketerize.bucketerize_config
      config[:mount_prefix] = mount_prefix
      Bucketerize.instance_variable_set(:@bucketerize_config, config)
    end

    def get_mount_prefix
      bucketerize_config[:mount_prefix]
    end
  end
end

# 引用 rails engine
require 'bucketerize/engine'
require 'bucketerize/rails_routes'

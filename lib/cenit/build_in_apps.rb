require 'cenit/build_in_apps/version'
require 'cenit/build_in_apps/error'
require 'cenit/build_in_apps/app_builder'

module Cenit
  module BuildInApps

    def self.included(m)
      m.extend(AppBuilder)
      apps_modules << m
    end

    module_function

    def apps_modules
      @apps_modules ||= []
    end

    def controllers
      @controllers ||= {}
    end

    def build_controllers_from(parent)
      apps_modules.each do |app_module|
        controller = Class.new(parent, &app_module.controller_def)
        controller.instance_variable_set(:@app_module, app_module)
        key = app_module.app_key
        Object.const_set(key.camelize + 'Controller', controller)
        controllers[key] = controller
      end
    end
  end
end

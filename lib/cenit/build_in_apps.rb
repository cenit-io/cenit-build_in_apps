require 'cenit/build_in_apps/version'
require 'cenit/build_in_apps/error'
require 'cenit/build_in_apps/app_builder'

module Cenit
  module BuildInApps

    def self.included(m)
      m.extend(AppBuilder)
      apps_modules << m

      # Create app engine
      engine = Class.new(::Rails::Engine)
      m.const_set('Engine', engine)

      # Fixing engine dir called location (check ::Rails::Engine#inerited for details)
      call_stack =
        if Kernel.respond_to?(:caller_locations)
          caller_locations.map { |l| l.absolute_path || l.path }
        else
          # Remove the line number from backtraces making sure we don't leave anything behind
          caller.map { |p| p.sub(/:\d+.*/, '') }
        end

      engine_dir = File.dirname(call_stack.detect { |p| p !~ %r[railties[\w.-]*/lib/rails|rack[\w.-]*/lib/rack] })

      engine.called_from = engine_dir

      assets_dir = engine_dir.split('/')
      assets_dir.pop(2)
      assets_dir = "#{assets_dir.join('/')}/app/assets"

      assets = []

      %w(javascripts stylesheets images).each do |dir|
        dir = "#{assets_dir}/#{dir}"
        Dir["#{dir}/**/*"].each do |file|
          next unless File.file?(file)
          if file.ends_with?('.scss')
            file = file[0..(file.length - 6)]
          end
          assets << file[(dir.length + 1)..file.length]
        end
      end

      unless assets.empty?
        engine.initializer :assets do
          Rails.application.config.assets.precompile += assets
        end
      end
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
        controller = Class.new(parent)
        controller.instance_variable_set(:@app_module, app_module)
        app_module.controller_defs.each do |controller_def|
          controller.class_eval(&controller_def)
        end
        key = app_module.app_key
        app_module.const_set('MainController', controller)
        if app_module.custom_layout
          controller.class_eval <<-RUBY
            layout '#{app_module.custom_layout}'
          RUBY
        end
        controller.class_eval <<-RUBY
          def self.local_prefixes
            ['#{app_module.controller_prefix}']
          end
        RUBY
        controllers[key] = controller
      end
    end
  end
end

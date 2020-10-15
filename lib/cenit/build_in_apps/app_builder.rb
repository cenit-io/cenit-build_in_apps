module Cenit
  module BuildInApps
    module AppBuilder
      extend self

      attr_reader :controller_def, :app_id, :document_types_defs

      def setups
        unless @setups
          @setups = []
          setup do
            ::Setup::Namespace.find_or_create_by(name: to_s).update(slug: app_key)
          end
        end
        @setups
      end

      def setup(&block)
        setups << block
      end

      def document_type(name, &block)
        unless @document_types_defs
          @document_types_defs = {}
        end
        @document_types_defs[name] = block
      end

      def controller(&block)
        @controller_def = block
      end

      def app_key(*args)
        if args.length == 0
          @app_key || app_name.underscore
        else
          @app_key = args[0].to_s
        end
      end

      def app_name(*args)
        if args.length == 0
          @app_name || to_s.split('::').last
        else
          @app_name = args[0].to_s
        end
      end

      def app
        Cenit::BuildInApp.find(app_id)
      end
    end
  end
end
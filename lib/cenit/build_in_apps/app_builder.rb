module Cenit
  module BuildInApps
    module AppBuilder
      extend self

      attr_reader :controller_def, :app_id

      def document_types_defs
        @document_types_defs ||= {}
      end

      def custom_layout(*args)
        if args.length > 0
          layout = args[0]
          @custom_layout =
            if layout.is_a?(String)
              args[0]
            elsif layout
              controller_prefix
            else
              nil
            end
        end
        @custom_layout
      end

      def installers
        unless @installers
          @installers = []
          install do
            ::Setup::Namespace.find_or_create_by(name: to_s).update(slug: app_key)
          end
        end
        @installers
      end

      def install(&block)
        setups << block
      end

      def setups
        @setups ||= []
      end

      def setup(&block)
        setups << block
      end

      def document_type(name, &block)
        document_types_defs[name] = block
      end

      def controller(&block)
        @controller_def = block
      end

      def short_name
        to_s.split('::').last
      end

      def app_key(*args)
        if args.length == 0
          @app_key || short_name.underscore
        else
          @app_key = args[0].to_s
        end
      end

      def app_name(*args)
        if args.length == 0
          @app_name || short_name
        else
          @app_name = args[0].to_s
        end
      end

      def app
        Cenit::BuildInApp.find(app_id)
      end

      def controller_prefix(*args)
        if args.length > 0
          @controller_prefix = args[0]
        end
        @controller_prefix = begin
          tokens = to_s
                     .split('::')
                     .map(&:underscore)
          tokens.pop
          tokens << app_key
          tokens.join('/')
        end
      end
    end
  end
end
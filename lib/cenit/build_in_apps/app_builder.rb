module Cenit
  module BuildInApps
    module AppBuilder
      extend self

      attr_reader :controller_def, :app_id

      def document_types_defs
        @document_types_defs ||= {}
      end

      def file_types_defs
        @file_types_defs ||= {}
      end

      def types_options
        @types_options ||= {}
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
        unless @setups
          @setups = []
          setup do
            app = self.app
            config = app.configuration
            redirect_uris = config.redirect_uris || []
            oauth_callback_uri = "#{Cenit.homepage}/oauth/callback"
            unless redirect_uris.include?(oauth_callback_uri)
              redirect_uris << oauth_callback_uri
              config.redirect_uris = redirect_uris
              app.save
              puts "OAuth callback URI added: #{oauth_callback_uri}"
            end
          end
        end
        @setups
      end

      def setup(&block)
        setups << block
      end

      def document_type(name, options = nil, &block)
        fail "#{name} already defined as a file" if file_types_defs.key?(name)
        types_options[name] = options if options
        document_types_defs[name] = block
      end

      def file_type(name, options = nil, &block)
        fail "#{name} already defined as a document" if document_types_defs.key?(name)
        types_options[name] = options if options
        file_types_defs[name] = block
      end

      def controller(&block)
        @controller_def = block
      end

      def controller?
        !!controller_def
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
        @controller_prefix = args[0] if args.length > 0
        @controller_prefix ||= begin
          tokens = to_s.split('::').map(&:underscore)
          tokens.pop
          tokens << app_key
          tokens.join('/')
        end
      end
    end
  end
end
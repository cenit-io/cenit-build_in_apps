module Cenit
  module BuildInApps
    module OauthHelpers

      def self.included(m)
        m.controller do

          def if_can?(action, model = nil)
            error_description = nil
            if (auth_header = request.headers['Authorization'])
              auth_header = auth_header.to_s.squeeze(' ').strip.split(' ')
              if auth_header.length == 2
                access_token = Cenit::OauthAccessToken.where(token_type: auth_header[0], token: auth_header[1]).first
                if access_token&.alive?
                  if (user = access_token.user)
                    User.current = user
                    if access_token.set_current_tenant!
                      access_grant = Cenit::OauthAccessGrant.where(application_id: access_token.application_id).first
                      if access_grant
                        oauth_scope = access_grant.oauth_scope
                        if oauth_scope.can?(action, model)
                          yield if block_given?
                        else
                          error_description = 'The requested action is out of the access token scope'
                        end
                      else
                        error_description = 'Access grant revoked or moved outside token tenant'
                      end
                    end
                  else
                    error_description = 'The token owner is no longer an active user'
                  end
                else
                  error_description = 'Access token is expired or malformed'
                end
              else
                error_description = 'Malformed authorization header'
              end
            end
            if error_description
              response.headers['WWW-Authenticate'] = %(Bearer realm="example",error="insufficient_scope",error_description=#{error_description})
              render json: { error: 'insufficient_scope', error_description: error_description }, status: :forbidden
            end
          end
        end
      end
    end
  end
end
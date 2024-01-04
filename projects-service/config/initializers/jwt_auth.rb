#module JwtAuth
=begin
  class Middleware

    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo+Qp0gVd4gFHzjCcQtJCekufLT4UkF+o+qy0doblqTUpc4O/2H79Sjk0OOQGr2DuX3TwEmSa6A4v/3XA4xb7Fa84YiyER0viZaGyO/nGCGlMY2WOxpPYQ8nIjkWP3UDtlT0PsSom+OhJPrtus1o2OiIhXSMoIyr3pX5euIh6GtFrb1KUYuD9PHu7YxtGopPnSukIbZ+H/sdlxQKv/9xnA+oJn7bwoK68wbsiu8iVdd/yG3FolYeKXfGVAM88ZB7x3LhsgkMeWDMsvqgZ4jtdcwUsAzm22xoEYnGQc2EISyPR9utKmr/qjWpaN5PW2/KrY2BjQ+Vm3m2Oet28VwLRZQIDAQAB
-----END PUBLIC KEY-----"

    def initialize(app)
      @app = app
      @public_key = OpenSSL::PKey::RSA.new(KEYCLOAK_PUBLIC_KEY)
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.env['HTTP_AUTHORIZATION'].present?
        begin
          token = request.env['HTTP_AUTHORIZATION'].split(' ').last
          payload, _ = JWT.decode(token, @public_key, true, { algorithm: 'RS256' })
          env['user'] = payload
        rescue JWT::DecodeError => e
          return [401, {'Content-Type' => 'application/json'}, [{ error: "Błąd autentykacji: #{e.message}" }.to_json]]
        end
      else
        return [401, {'Content-Type' => 'application/json'}, [{ error: 'Brak nagłówka Authorization' }.to_json]]
      end

      @app.call(env)
    end
  end
end
=end


#Rails.application.config.middleware.use JwtAuth::Middleware
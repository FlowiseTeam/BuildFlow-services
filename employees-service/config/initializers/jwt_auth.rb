module JwtAuth
  class Middleware

    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl7S4wynBLsKJgT+aehl0mqhb+zSRlETNDAxDwEGU/XTFpli31IxMeEklsG9Ug6uqedw4/v6YoY5hKRFd3RdnMVHUuJOWvMDcbUR05A7KIPk1Z75R+eU4pJSMI8oOdMAXFaxiiQ20XKwM1m06jr51AAsv4noEjaiKXBz6fPxWApuqQT8gGAIN+L81TU9gSTwAvNNezOd9Jg7OvBk4+dapALTR5xtrU6zspVu8TQ9yPLuOmuNCifYE+jJgA09Si3lVAKpi977wR1Cwqgijii8+pAgmDaeINB7vF8M3tns14nouP/m0XujoFLmPvxpV32I0dDj9ZxK59jPryVTvXhE3UQIDAQAB
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


Rails.application.config.middleware.use JwtAuth::Middleware
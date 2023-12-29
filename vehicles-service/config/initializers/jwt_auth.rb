module JwtAuth
  class Middleware

    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvw1OL5m/b+f44VNYl8Jt6bZ/cq/qDA7azYp64c4wFSqMp9gns0ZtwgPIban0j8t+zwUuePRfZdOnoHR/cNh09dy/6Fku9/d9xNWoxePYcvPidpbBKEksffuOURifN7Qn/WBQyaPWpyoTwfGrPImHigWqkbmRRTlFg0FhKfZDfC84tub0S2T6A25hwPdUmtQrR6RAAWzhS4PSFry3a8EoiwU5KhnFLs3AFg76tejmtGG0WQqtPFmBdTAY6oCGMOT7cdfEusORpqWLpGg6dmKqqLC6vof6Jik5Dyt1mJmZwExIUTV3tUrZ8dlhAE9K+316A+Q1BF2K6d9C+FWpMBgfcwIDAQAB
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
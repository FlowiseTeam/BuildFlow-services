module JwtAuth
begin
  class Middleware

    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5+q69uGTzchQfzvzL1EQHrMgPMbppFVGIBdhzpSdCBRjbHahX8kP27NvCgem8/qIIjTQEQf3EC085hDjx4w9FL8zWgEz9S/X3UQ3IlHu+0lIm93ljJbNOLeDOrsHWiU1AVGO54UF0/Sfxt6CcC8n3kYWiJr2heGrWhf6hyTasgcZMz0aPRfYFlDNtCrFcyHQ1QCXamJ4nfJ3NykowHwU+ywJNPib8s2jcPE/8gEEZhZA7imIB+Sir74+9wtPEaIhgZz1c4Zhwk99HwFAamvVmjT2pbIPjFOxM5BMfh+wc6vhZQpsTAt4gTpLkbpGHJg/mjPWXWdX4uAave5XNR+KewIDAQAB
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
end


Rails.application.config.middleware.use JwtAuth::Middleware
module JwtAuth
begin
  class Middleware

    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA38Py5OsxusyAYzNghc//xN6JD+v1X9bZ2jdERR/PEn8RatZIiHFqwVY81uBx8VprW/MaZIoEa7N3SOa1Skeyxh1jkYwrGTDwhhpi3L5abhr2Ae1BhLc9dRRSpqZkOkAor2FXmMfCI01vzF0DaCbToyyGGbiYLpz+fmu+B+Br+YlQtFuJM7VfV9kevMZ88mij39WSz7+C7dKbMdnQpfVGyoVowyExbBeCEJ8BNYhIFx4PhwojbjJy61QQmwRshtGHsuIIlS0BHS+IjELW07DTUmmMXYbt7P+hCS08faC26HEPfyOAHnHaXcTY0iShrmqNtA7Iv+74n/TdA6FPFH/WBQIDAQAB
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
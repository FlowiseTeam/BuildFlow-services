module JwtAuth
begin
  class Middleware

    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv5KXXDPAVuP9GjOoGZJL7DGReCR4IIdF2wFkt0nsd0cKmwuWP1UCOl12eVF1dn03i4x5IktiCjn7PFUoLUHCZhv5n1FELxc3sNBVkGGrb8OD4K7594Z++3KpVojjG5bWRRcEImXT4eCjUDJR+JwAcgRFZJCKIgNBRPCRi0isSVNG3iFI83Q2Q+aiSfbZoi7cVvSpKQZU7FlhVRNFj3jLOzZjHr5t7Oz5GuksIWRNKzFVX4CF2IUZoU6KaTI6aPrU4trHZrX8OHyNmeM7T8aGGIcjef/AotQlx/VyKozi9oE16YBW1W2epC6xpomLcvlnHU52MjxvA8e7pYUjoS/gzQIDAQAB
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
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from starlette.responses import RedirectResponse

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv5KXXDPAVuP9GjOoGZJL7DGReCR4IIdF2wFkt0nsd0cKmwuWP1UCOl12eVF1dn03i4x5IktiCjn7PFUoLUHCZhv5n1FELxc3sNBVkGGrb8OD4K7594Z++3KpVojjG5bWRRcEImXT4eCjUDJR+JwAcgRFZJCKIgNBRPCRi0isSVNG3iFI83Q2Q+aiSfbZoi7cVvSpKQZU7FlhVRNFj3jLOzZjHr5t7Oz5GuksIWRNKzFVX4CF2IUZoU6KaTI6aPrU4trHZrX8OHyNmeM7T8aGGIcjef/AotQlx/VyKozi9oE16YBW1W2epC6xpomLcvlnHU52MjxvA8e7pYUjoS/gzQIDAQAB
-----END PUBLIC KEY-----'''


@app.middleware("http")
async def jwt_middleware(request: Request, call_next):
    if 'Authorization' in request.headers:
        token = request.headers.get('Authorization').split(' ')[1]

        try:
            payload = jwt.decode(token, PUBLIC_KEY, algorithms=["RS256"], audience='account')

            request.state.user = payload
        except JWTError as e:
            return JSONResponse(
                status_code=401,
                content={"detail": f"Błąd autentykacji: {str(e)}"}
            )
    else:
        return JSONResponse(
            status_code=401,
            content={"detail": "Brak nagłówka Authorization"}
        )
    response = await call_next(request)
    return response

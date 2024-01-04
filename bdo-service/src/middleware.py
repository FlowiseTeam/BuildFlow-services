from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from starlette.responses import RedirectResponse

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAslzqAIV6CjJrnOdhYRSBQp5C6xHPc1LOGFhTWJxatd0YyqNF5ACcB9AERfBOD+Wwez3iL12tJCkaNC5bNiyPAU7aaZOtU7sJLAULVBNJ/vBFScnxU1Wso4Xao8bDOOSOd0cTnuk3NpgCorp4pTHpje8juD9f5VnCLNHSdjTQWKux6tR0jh9Tst1MFhlq3xbKxVu4g//iDUWdwyWOIJ0Ax/BX+OGVI5XdWzke5mePAIEESCUUQyIC0MCtrJwldRKoXD+MEk8dxsq5F/z0/LVgFPrLjtMzBymEaosQIzpcPNKGO072huuSgDgtxBkIFxDinJWKJ2x5CubN3WdyNDe2HQIDAQAB
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

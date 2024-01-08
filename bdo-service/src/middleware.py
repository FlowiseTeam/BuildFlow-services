from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from starlette.responses import RedirectResponse

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl7S4wynBLsKJgT+aehl0mqhb+zSRlETNDAxDwEGU/XTFpli31IxMeEklsG9Ug6uqedw4/v6YoY5hKRFd3RdnMVHUuJOWvMDcbUR05A7KIPk1Z75R+eU4pJSMI8oOdMAXFaxiiQ20XKwM1m06jr51AAsv4noEjaiKXBz6fPxWApuqQT8gGAIN+L81TU9gSTwAvNNezOd9Jg7OvBk4+dapALTR5xtrU6zspVu8TQ9yPLuOmuNCifYE+jJgA09Si3lVAKpi977wR1Cwqgijii8+pAgmDaeINB7vF8M3tns14nouP/m0XujoFLmPvxpV32I0dDj9ZxK59jPryVTvXhE3UQIDAQAB
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

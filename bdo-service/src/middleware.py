from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from starlette.responses import RedirectResponse

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5+q69uGTzchQfzvzL1EQHrMgPMbppFVGIBdhzpSdCBRjbHahX8kP27NvCgem8/qIIjTQEQf3EC085hDjx4w9FL8zWgEz9S/X3UQ3IlHu+0lIm93ljJbNOLeDOrsHWiU1AVGO54UF0/Sfxt6CcC8n3kYWiJr2heGrWhf6hyTasgcZMz0aPRfYFlDNtCrFcyHQ1QCXamJ4nfJ3NykowHwU+ywJNPib8s2jcPE/8gEEZhZA7imIB+Sir74+9wtPEaIhgZz1c4Zhwk99HwFAamvVmjT2pbIPjFOxM5BMfh+wc6vhZQpsTAt4gTpLkbpGHJg/mjPWXWdX4uAave5XNR+KewIDAQAB
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

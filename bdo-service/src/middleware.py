from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvw1OL5m/b+f44VNYl8Jt6bZ/cq/qDA7azYp64c4wFSqMp9gns0ZtwgPIban0j8t+zwUuePRfZdOnoHR/cNh09dy/6Fku9/d9xNWoxePYcvPidpbBKEksffuOURifN7Qn/WBQyaPWpyoTwfGrPImHigWqkbmRRTlFg0FhKfZDfC84tub0S2T6A25hwPdUmtQrR6RAAWzhS4PSFry3a8EoiwU5KhnFLs3AFg76tejmtGG0WQqtPFmBdTAY6oCGMOT7cdfEusORpqWLpGg6dmKqqLC6vof6Jik5Dyt1mJmZwExIUTV3tUrZ8dlhAE9K+316A+Q1BF2K6d9C+FWpMBgfcwIDAQAB
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

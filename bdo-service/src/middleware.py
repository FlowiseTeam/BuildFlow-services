from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from starlette.responses import RedirectResponse

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA38Py5OsxusyAYzNghc//xN6JD+v1X9bZ2jdERR/PEn8RatZIiHFqwVY81uBx8VprW/MaZIoEa7N3SOa1Skeyxh1jkYwrGTDwhhpi3L5abhr2Ae1BhLc9dRRSpqZkOkAor2FXmMfCI01vzF0DaCbToyyGGbiYLpz+fmu+B+Br+YlQtFuJM7VfV9kevMZ88mij39WSz7+C7dKbMdnQpfVGyoVowyExbBeCEJ8BNYhIFx4PhwojbjJy61QQmwRshtGHsuIIlS0BHS+IjELW07DTUmmMXYbt7P+hCS08faC26HEPfyOAHnHaXcTY0iShrmqNtA7Iv+74n/TdA6FPFH/WBQIDAQAB
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

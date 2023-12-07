from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError

app = FastAPI()


PUBLIC_KEY = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8Gy+sTjI41uzAIxsmXPgm9D/scrbqeBHaUwpA6PvlGWpdaQd8GY8ObQd4NMUK1vk3OwHPk0mpMR7trUMWjjWgNEl6exfF3b/GHZpEW8hW+nB11yIKqE4283Jly0WFJl93//tBha/caTvuRbYs5l0eB1I0eYuG1Z7aG77oKIushLfJrvaLxVyPkt58MP+WZeI8I14ydVHEfVsOtoDvJSK6zxx2x0KuPu4ogdgYHvm+likn2xuyUPRvr7kHWCr6GL+71VoBd3v+fYaHiEc5sGcGWGA84lwqfUYbFXkoyDzmAGZKqOqYnmSGGADARvVOxuIeLTpGAM5PK29X9q2OKnsFQIDAQAB
-----END PUBLIC KEY-----'''


@app.middleware("http")
async def jwt_middleware(request: Request, call_next):
    if 'Authorization' in request.headers:
        token = request.headers.get('Authorization').split(' ')[1]

        try:
            payload = jwt.decode(token, PUBLIC_KEY, algorithms=["RS256"], audience='postman_test')
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

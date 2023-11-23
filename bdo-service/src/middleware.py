from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from src.app import PUBLIC_KEY

app = FastAPI()




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

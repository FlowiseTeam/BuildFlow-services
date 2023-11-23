from fastapi import FastAPI, APIRouter
from dotenv import load_dotenv


from src.middleware import jwt_middleware
from src.kpo import router as kpo_router
from src.keo import router as keo_router

load_dotenv()
main_router = APIRouter(prefix="/api")
main_router.include_router(kpo_router.router, prefix='/kpo')
main_router.include_router(keo_router.router, prefix='/keo')

app = FastAPI()

app.middleware("http")(jwt_middleware)
app.include_router(main_router)

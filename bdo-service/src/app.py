from fastapi import FastAPI, APIRouter

from src.kpo import router as kpo_router
from src.keo import router as keo_router

main_router = APIRouter(prefix="/api")
main_router.include_router(kpo_router.router, prefix='/kpo')
main_router.include_router(keo_router.router, prefix='/keo')

app = FastAPI()
app.include_router(main_router)

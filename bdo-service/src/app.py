from fastapi import FastAPI, APIRouter
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

from src.middleware import jwt_middleware
from src.kpo import router as kpo_router
from src.keo import router as keo_router
from src.bdo_info import router as bdo_info_router


main_router = APIRouter(prefix="/api")
main_router.include_router(kpo_router.router, prefix='/kpo')
main_router.include_router(keo_router.router, prefix='/keo')
main_router.include_router(bdo_info_router.router, prefix='/bdo-info')

app = FastAPI()


origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.middleware("http")(jwt_middleware)
app.include_router(main_router)

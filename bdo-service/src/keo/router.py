from fastapi import APIRouter
from src.mongodb import get_database


router = APIRouter(
    tags=['KEO']
)

db = get_database()

@router.get('/')
def get_cards():
    collection = db.get_collection('kpo')
    test = collection.find_one()
    return f"Hello from KEO module ,{test}"
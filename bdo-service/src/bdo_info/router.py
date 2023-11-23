from fastapi import APIRouter, HTTPException, status
from fastapi.responses import Response
from bson import ObjectId
from src.mongodb import get_database
from src.kpo.schemas import Card, CardCreate, CardCollection

router = APIRouter(
    tags=['KPO']
)

db = get_database()
bdo_info_collection = db.get_collection('bdo_info')


@router.get('/')
def get_cards() -> CardCollection:
    return CardCollection(cards=bdo_info_collection.find(limit=1000))


@router.get('/{card_id}')
def show_card(card_id: str) -> Card:
    return bdo_info_collection.find_one({"_id": ObjectId(card_id)})


@router.post('/', status_code=201)
def create_new_card(card: CardCreate) -> dict:
    card_dict = card.model_dump()
    result = bdo_info_collection.insert_one(card_dict)

    # Convert ObjectId to string
    return {"created_id": str(result.inserted_id)}


@router.put('/{card_id}')
def update_card(card_id: str):
    return "The function is not implemented"


@router.delete("/{card_id}")
def delete_student(card_id: str):
    delete_result = bdo_info_collection.delete_one({"_id": ObjectId(card_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    raise HTTPException(status_code=404, detail=f"Card {card_id} not found")
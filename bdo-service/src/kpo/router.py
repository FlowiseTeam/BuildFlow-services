from fastapi import APIRouter, HTTPException, status
from fastapi.responses import Response
from bson import ObjectId
from src.mongodb import get_database
from src.kpo.schemas import Card, BdoCardCreate, CardCollection
from src.kpo import kpo

router = APIRouter(
    tags=['KPO']
)

db = get_database()
kpo_collection = db.get_collection('kpo')


@router.get('/')
def get_cards() -> CardCollection:
    return CardCollection(cards=kpo_collection.find(limit=100))


@router.get('/{card_id}')
def show_card(card_id: str) -> Card:
    return kpo_collection.find_one({"_id": ObjectId(card_id)})


@router.post('/', status_code=201)
def create_new_card(card: BdoCardCreate) -> dict:

    # response = kpo.create_planned_card(access_token, card)

    card_dict = card.model_dump()
    # card_dict['KpoId'] = response['KpoId']
    result = kpo_collection.insert_one(card_dict)

    return {"created_id": str(result.inserted_id)}


@router.put('/{card_id}')
def update_card(card_id: str):
    return "The function is not implemented"


@router.delete("/{card_id}")
def delete_card(card_id: str):
    # kpo_id = kpo_collection.find_one({"_id": ObjectId(card_id)})['kpo_id']
    # response = kpo.delete_planned_card(access_token, kpo_id)

    delete_result = kpo_collection.delete_one({"_id": ObjectId(card_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    raise HTTPException(status_code=404, detail=f"Card {card_id} not found")

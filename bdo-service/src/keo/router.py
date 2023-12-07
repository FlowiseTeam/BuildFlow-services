from fastapi import APIRouter, HTTPException, status
from fastapi.responses import Response
from bson import ObjectId

from src.mongodb import get_database
from src.keo.schemas import CreateRecord

router = APIRouter(
    tags=['KPO']
)

db = get_database()
keo_collection = db.get_collection('keo')


@router.post('/', status_code=201)
def create_new_record(record: CreateRecord) -> dict:
    record_dict = record.model_dump()
    result = keo_collection.insert_one(record_dict)

    return {"created_id": str(result.inserted_id)}


@router.put('/{record_id}')
def update_card(record_id: str):
    return "The function is not implemented"


@router.delete("/{record_id}")
def delete_record(record_id: str):
    delete_result = keo_collection.delete_one({"_id": ObjectId(record_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    raise HTTPException(status_code=404, detail=f"Card {record_id} not found")
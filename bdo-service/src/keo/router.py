import requests

from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.responses import Response
from bson import ObjectId

from src.mongodb import get_database
from src.keo.schemas import CreateRecord
from src import token
from src.keo import keo


router = APIRouter(
    tags=['KPO']
)

db = get_database()
keo_collection = db.get_collection('keo')


@router.post('/', status_code=201)
def create_new_record(record: CreateRecord, access_token: str = Depends(token.fetch_token)) -> dict:
    # try:
    #     created_record = keo.create_generated_record(access_token, record)
    # except requests.exceptions.RequestException as e:
    #     raise HTTPException(status_code=400, detail=str(e))
    # except Exception as e:
    #     raise HTTPException(status_code=500, detail="Internal Server Error")

    record_dict = record.model_dump()
    record_dict['KeoGeneratedId'] = "test response"


    result = keo_collection.insert_one(record_dict)

    return {"created_id": str(result.inserted_id)}


@router.put('/{record_id}')
def update_record(record_id: str):
    return "The function is not implemented"


@router.delete("/{record_id}")
def delete_record(record_id: str, access_token: str = Depends(token.fetch_token)) -> Response:
    keo_generated_id = keo_collection.find_one({"_id": ObjectId(record_id)}).get('KeoGeneratedId')

    # try:
    #     keo.delete_generated_record(access_token, keo_generated_id)
    # except requests.exceptions.RequestException as e:
    #     raise HTTPException(status_code=400, detail=str(e))
    # except Exception as e:
    #     raise HTTPException(status_code=500, detail="Internal Server Error")

    delete_result = keo_collection.delete_one({"_id": ObjectId(record_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    raise HTTPException(status_code=404, detail=f"Card {record_id} not found")


@router.get("/waste-quantity/{keo_id}")
def get_waste_quantity(keo_id: str, access_token: str = Depends(token.fetch_token)) -> dict:
    card_info = keo.get_keo_card_info(access_token, keo_id)
    waste_mass = card_info.get('WasteMass')

    return {"wasteMass": waste_mass}

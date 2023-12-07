from fastapi import APIRouter, HTTPException
from src.mongodb import get_database
from src.bdo_info.schemas import *

router = APIRouter(
    tags=['KPO']
)

db = get_database()
bdo_info_collection = db.get_collection('bdo-info')


@router.get('/kpo')
def get_bdo_info_for_kpo() -> BdoInfoResponse:
    try:
        documents = list(bdo_info_collection.find({"type": {"$in": ["carrier", "receiver", "wasteCode"]}}))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    carriers = [CarrierInfo(**doc) for doc in documents if doc.get("type") == "carrier"]
    receivers = [ReceiverInfo(**doc) for doc in documents if doc.get("type") == "receiver"]
    waste_codes = [WasteCode(**doc) for doc in documents if doc.get("type") == "wasteCode"]

    return BdoInfoResponse(carriers=carriers, receivers=receivers, wasteCodes=waste_codes)


@router.get('/keo')
def get_bdo_info_for_keo() -> CardCollection:
    return CardCollection(cards=bdo_info_collection.find({"type": "card"}))



@router.post('/kpo')
def add_bdo_info():
    return bdo_info_collection.find(limit=1000)
from fastapi import APIRouter, HTTPException, status
from fastapi.responses import Response
from bson import ObjectId

from src.mongodb import get_database
from src.bdo_info.schemas import *
from src.bdo_info import bdo_info


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



# TODO needs access_token

# @router.post('/')
# def add_bdo_company(company: AddCompany) -> dict:
#     company_details = bdo_info.get_company_details(access_token, company.get('name'))
#     company_details['type'] = company.get('type')
#
#     if company.get('type') != "receiver":
#         company_dict = CreateCarrierInfo(**company_details).model_dump()
#         return bdo_info_collection.insert_one(company_dict)
#
#     company_details['EupIds'] = bdo_info.get_eup_ids(access_token, company_details['companyId'])
#     company_dict = CreateReceiverInfo(**company_details).model_dump()
#
#     return bdo_info_collection.insert_one(company_dict)


@router.delete("/{object_id}")
def delete_bdo_info(object_id: str):
    delete_result = bdo_info_collection.delete_one({"_id": ObjectId(object_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    raise HTTPException(status_code=404, detail=f"{object_id} not found")

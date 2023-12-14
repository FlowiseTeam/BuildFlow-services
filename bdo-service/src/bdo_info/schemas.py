from enum import Enum
from typing import Optional, Annotated, List
from pydantic import Field
from pydantic.functional_validators import BeforeValidator
from pydantic import BaseModel


PyObjectId = Annotated[str, BeforeValidator(str)]


class CompanyType(str, Enum):
    carrier = 'carrier'
    receiver = 'receiver'


class AddCompany(BaseModel):
    name: str
    type: CompanyType


class CarrierInfo(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    companyId: str
    name: str
    registrationNumber: str
    nip: str
    type: str


class CreateCarrierInfo(BaseModel):
    companyId: str
    name: str
    registrationNumber: str
    nip: str
    type: str


class ReceiverInfo(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    companyId: str
    name: str
    registrationNumber: str
    nip: str
    EupIds: list[dict]
    type: str


class CreateReceiverInfo(BaseModel):
    companyId: str
    name: str
    registrationNumber: str
    nip: str
    EupIds: list[dict]
    type: str


class WasteCode(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    code: str
    description: str
    type: str
    WasteCodeId: int


class CreateWasteCode(BaseModel):
    code: str
    description: str
    type: str
    WasteCodeId: int


class BdoInfoResponse(BaseModel):
    carriers: List[CarrierInfo]
    receivers: List[ReceiverInfo]
    wasteCodes: List[WasteCode]


class Card(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    KeoId: str
    name: str


# class CreateCard(BaseModel): # TODO find way to handle new keo cards
#     KeoId: str
#     name: str


class CardCollection(BaseModel):
    cards: List[Card]

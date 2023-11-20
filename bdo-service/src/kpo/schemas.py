from pydantic import BaseModel, Field, ConfigDict
from pydantic.functional_validators import BeforeValidator
from typing import Optional, List
from bson import ObjectId
from typing_extensions import Annotated


# Pydantic schema for User input
class CardCreate(BaseModel):
    carrier_company_id: str
    ReceiverCompanyId: str
    ReceiverEupId: str
    WasteCodeId: int
    VehicleRegNumber: str
    WasteMass: int
    PlannedTransportTime: str  # TODO 2023-11-18T00:17:52.335Z
    WasteProcessId: int
    CertificateNumberAndBoxNumbers: str
    AdditionalInfo: str
    WasteCodeExtended: bool
    WasteCodeExtendedDescription: str
    HazardousWasteReclassification: bool = True
    HazardousWasteReclassificationDescription: str
    IsWasteGenerating: bool = False
    WasteGeneratedTerytPk: str
    WasteGeneratingAdditionalInfo: str


  # "CarrierCompanyId":
  # "ReceiverCompanyId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  # "ReceiverEupId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  # "WasteCodeId": 0,
  # "VehicleRegNumber": "string",
  # "WasteMass": 0,
  # "PlannedTransportTime": "2023-11-18T00:17:52.335Z",
  # "WasteProcessId": 0,
  # "CertificateNumberAndBoxNumbers": "string",
  # "AdditionalInfo": "string",
  # "WasteCodeExtended": true,
  # "WasteCodeExtendedDescription": "string",
  # "HazardousWasteReclassification": true,
  # "HazardousWasteReclassificationDescription": "string",
  # "IsWasteGenerating": false,
  # "WasteGeneratedTerytPk": "string",
  # "WasteGeneratingAdditionalInfo": "string"
# Pydantic schema for User output


PyObjectId = Annotated[str, BeforeValidator(str)]


class Card(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    carrier_company_id: str
    ReceiverCompanyId: str
    ReceiverEupId: str
    WasteCodeId: int
    VehicleRegNumber: str
    WasteMass: int
    PlannedTransportTime: str  # TODO 2023-11-18T00:17:52.335Z
    WasteProcessId: int
    CertificateNumberAndBoxNumbers: str
    AdditionalInfo: str
    WasteCodeExtended: bool
    WasteCodeExtendedDescription: str
    HazardousWasteReclassification: bool = True
    HazardousWasteReclassificationDescription: str
    IsWasteGenerating: bool = False
    WasteGeneratedTerytPk: str
    WasteGeneratingAdditionalInfo: str
    model_config = ConfigDict(arbitrary_types_allowed=True)


class CardCollection(BaseModel):
    cards: List[Card]

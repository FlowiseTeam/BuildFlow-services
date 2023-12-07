from pydantic import BaseModel, Field, ConfigDict
from pydantic.functional_validators import BeforeValidator
from typing import Optional, List
from typing_extensions import Annotated


class BdoCardCreate(BaseModel):
    CarrierCompanyId: str
    ReceiverCompanyId: str
    ReceiverEupId: str
    WasteCodeId: int
    VehicleRegNumber: str
    WasteMass: int
    PlannedTransportTime: str
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


PyObjectId = Annotated[str, BeforeValidator(str)]


class Card(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    CarrierCompanyId: str
    KpoId: str
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

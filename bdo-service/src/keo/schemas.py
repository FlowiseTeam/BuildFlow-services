from pydantic import BaseModel, Field, ConfigDict
from pydantic.functional_validators import BeforeValidator
from typing import Optional, List, Annotated


PyObjectId = Annotated[str, BeforeValidator(str)]


class Record(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    KeoId: str
    KeoGeneratedId: str
    WasteMassInstallation: float
    WasteMassExcludingInstallation: float
    WasteFromServices: bool = True
    CommuneId: Optional[str] = None
    ManufactureDate: str
    HazardousWasteReclassification: bool
    model_config = ConfigDict(arbitrary_types_allowed=True)


class CreateRecord(BaseModel):
    KeoId: str
    WasteMassInstallation: float
    WasteMassExcludingInstallation: float
    WasteFromServices: bool = True
    CommuneId: Optional[str] = None
    ManufactureDate: str
    HazardousWasteReclassification: bool


class RecordCollection(BaseModel):
    records: List[Record]

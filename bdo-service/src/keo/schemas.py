from datetime import datetime

from pydantic import BaseModel, Field, ConfigDict
from pydantic.functional_validators import BeforeValidator
from typing import Optional, List, Annotated


PyObjectId = Annotated[str, BeforeValidator(str)]


class Record(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    KeoId: str
    KeoGeneratedId: str
    WasteMassInstallation: int
    WasteMassExcludingInstallation: str
    WasteFromServices: bool = True
    # CommuneId: str ???
    ManufactureDate: datetime
    HazardousWasteReclassification: bool
    model_config = ConfigDict(arbitrary_types_allowed=True)


class CreateRecord(BaseModel):
    KeoId: str
    WasteMassInstallation: int
    WasteMassExcludingInstallation: str
    WasteFromServices: bool = True
    # CommuneId: str ???
    ManufactureDate: datetime
    HazardousWasteReclassification: bool


class RecordsCollection(BaseModel):
    records: List[Record]

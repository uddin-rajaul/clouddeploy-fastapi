from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr


class EmployeeCreate(BaseModel):
    name: str
    email: EmailStr
    department: str
    job_title: str


class EmployeeUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
    department: str | None = None
    job_title: str | None = None
    is_active: bool | None = None


class EmployeeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: EmailStr
    department: str
    job_title: str
    is_active: bool
    updated_at: datetime | None = None
    created_at: datetime
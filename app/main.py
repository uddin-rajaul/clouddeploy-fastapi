from fastapi import FastAPI
from app.routers.employees import router as employee_router


app = FastAPI(
    title="CloudDeploy API",
    version="0.1.0"
)
app.include_router(employee_router) 
@app.get("/")
def root():
    return {
        "message": "Welcome to CloudDeploy API"
    }

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }

from fastapi import FastAPI

app = FastAPI(
    title="CloudDeploy API",
    version="0.1.0"
)

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

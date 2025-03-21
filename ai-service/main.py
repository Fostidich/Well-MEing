import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"message": "Service is running"}


@app.post("/mirror")
def mirror(data: dict):
    return data


@app.get("/ping")
def ping():
    return "pong"


@app.get("/health")
def health_check():
    return {"status": "ok"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

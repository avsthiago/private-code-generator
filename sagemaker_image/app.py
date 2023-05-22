import uvicorn
from fastapi import FastAPI, Request, Response, status
import json
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

app = FastAPI()


@app.get("/ping")
async def ping():
    return Response(status_code=status.HTTP_200_OK)


@app.post("/invocations")
async def invocations(request: Request):
    json_request: dict = await request.json()
    inputs: str = json_request["inputs"]
    parameters: dict = json_request["parameters"]
    logger.info(f"Received data: {json_request}")
    generated_text = "Never gonna give you up. Never gonna let you down"
    return {"generated_text": generated_text, "status": 200}
from fastapi import FastAPI, Request, Response, status
import logging
import boto3
import os
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
    PreTrainedTokenizer,
    PreTrainedModel,
    GenerationConfig,
)
import torch

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


bucket_name = os.environ.get("MODEL_BUCKET_NAME")
model_key_prefix = os.environ.get("MODEL_KEY_PREFIX")
local_model_dir = "/opt/ml/model"

# create the local model directory if it does not exist
if not os.path.exists(local_model_dir):
    os.makedirs(local_model_dir)

# copy all the model files from S3 to the local model directory
s3 = boto3.resource("s3")
bucket = s3.Bucket(bucket_name)
for obj in bucket.objects.filter(Prefix=model_key_prefix):
    if obj.key != model_key_prefix:
        bucket.download_file(
            obj.key, os.path.join(local_model_dir, obj.key.split("/")[-1])
        )


class SantaCoder:
    def __init__(self, pretrained: str, device: str = "cuda"):
        self.pretrained: str = pretrained
        self.device: str = device
        self.model: PreTrainedModel = AutoModelForCausalLM.from_pretrained(
            pretrained, trust_remote_code=True
        )
        self.model.to(device=self.device)
        self.tokenizer: PreTrainedTokenizer = AutoTokenizer.from_pretrained(
            pretrained, trust_remote_code=True
        )
        self.generation_config: GenerationConfig = GenerationConfig.from_model_config(
            self.model.config
        )
        self.generation_config.pad_token_id = self.tokenizer.eos_token_id

    def generate(self, query: str, parameters: dict) -> str:
        input_ids: torch.Tensor = self.tokenizer.encode(query, return_tensors="pt").to(
            self.device
        )
        config: GenerationConfig = GenerationConfig.from_dict(
            {**self.generation_config.to_dict(), **parameters}
        )
        output_ids: torch.Tensor = self.model.generate(
            input_ids, generation_config=config
        )
        output_text: str = self.tokenizer.decode(
            output_ids[0], skip_special_tokens=True, clean_up_tokenization_spaces=False
        )
        return output_text


# load the model
model = SantaCoder(local_model_dir, device="cpu")

# start the API
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
    generated_text: str = model.generate(inputs, parameters)
    return {"generated_text": generated_text, "status": 200}

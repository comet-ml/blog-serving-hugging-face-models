import intel_pytorch_extension as ipex 

from transformers import DistilBertTokenizer, DistilBertForSequenceClassification
from typing import List, Optional
import torch
from fastapi import FastAPI
import numpy as np
import os
import transformers
from pydantic import BaseModel

transformers.logging.set_verbosity_error()
ipex.enable_auto_mixed_precision(mixed_dtype = torch.bfloat16) 

# Parse args
class ModelInference:
    def __init__(self):
        # Set the number of threads to be 1 for better parallelisation
        torch.set_num_threads(1)
        torch.set_grad_enabled(False)
        
        self.tokenizer = DistilBertTokenizer.from_pretrained('distilbert-base-uncased')
        model = DistilBertForSequenceClassification.from_pretrained('distilbert-base-uncased')
        #model = torch.quantization.quantize_dynamic(model, {torch.nn.Linear}, dtype=torch.qint8)
        model = model.to(ipex.DEVICE).eval()
        model = torch.jit.script(model)

        self.model = model

    def predict(self, message: str) -> List[np.float32]:
        with torch.no_grad():
            inputs = self.tokenizer(message, return_tensors="pt")
            labels = torch.tensor([1]).unsqueeze(0)

            inputs = {x: inputs[x].to(ipex.DEVICE) for x in inputs}
            labels = labels.to(ipex.DEVICE)

            outputs = self.model(**inputs, labels=labels)
            res = outputs.logits.cpu().numpy().tolist()

        return res

class SimpleMessage(BaseModel):
    text: Optional[str] = 'test'

# Parameters are passed using environment variables
model_class = ModelInference()

app = FastAPI()

@app.get("/")
def run_prediction():
    prediction = model_class.predict('This is a test message, how awesome !')
    return {'prediction': prediction}

@app.post("/prediction")
def run_prediction(message: SimpleMessage):
    prediction = model_class.predict(message.text)
    return {'prediction': prediction}

@app.get("/health_check")
def run_health_check():
    return {'res': True}
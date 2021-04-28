from transformers import BertTokenizerFast, BertForSequenceClassification
from typing import List, Optional
import torch
from fastapi import FastAPI
import numpy as np
import os
import transformers
from pydantic import BaseModel

transformers.logging.set_verbosity_error()

# Parse args
class ModelInference:
    def __init__(self):
        self.tokenizer = BertTokenizerFast.from_pretrained('bert-base-uncased')
        self.model = BertForSequenceClassification.from_pretrained('bert-base-uncased')
    
    def predict(self, message: str) -> List[np.float32]:
        inputs = self.tokenizer(message, return_tensors="pt")
        labels = torch.tensor([1]).unsqueeze(0)
        outputs = self.model(**inputs, labels=labels)
        res = outputs.logits.detach().numpy().tolist()

        return res

class SimpleMessage(BaseModel):
    text: Optional[str] = 'test'

model_class = ModelInference()

app = FastAPI()

@app.get("/")
async def run_prediction():
    prediction = model_class.predict('This is a test message, how awesome !')
    return {'prediction': prediction}

@app.post("/prediction")
async def run_prediction(message: SimpleMessage):
    prediction = model_class.predict(message.text)
    return {'prediction': prediction}

@app.get("/health_check")
async def run_health_check():
    return {'res': True}
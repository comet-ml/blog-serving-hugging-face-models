from transformers import BertTokenizer, DistilBertTokenizer, BertForSequenceClassification, DistilBertForSequenceClassification
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
    def __init__(self, args):
        # Set the number of threads to be 1 for better parallelisation
        torch.set_num_threads(1)
        torch.set_grad_enabled(False)
        
        if args['model'] == 'Bert':
            self.tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
            model = BertForSequenceClassification.from_pretrained('bert-base-uncased')
        elif args['model'] == 'DistilBert':
            self.tokenizer = DistilBertTokenizer.from_pretrained('distilbert-base-uncased')
            model = DistilBertForSequenceClassification.from_pretrained('distilbert-base-uncased')
        else:
            raise ValueError('Not a valid model name, enter one of [Bert, DistilBert]')
        
        if args['quantize']:
            model = torch.quantization.quantize_dynamic(model, {torch.nn.Linear}, dtype=torch.qint8)
        
        self.model = model

    
    def predict(self, message: str) -> List[np.float32]:
        with torch.no_grad():
            inputs = self.tokenizer(message, return_tensors="pt")
            labels = torch.tensor([1]).unsqueeze(0)
            outputs = self.model(**inputs, labels=labels)
            res = outputs.logits.numpy().tolist()

        return res

class SimpleMessage(BaseModel):
    text: Optional[str] = 'test'

# Parameters are passed using environment variables
args = {
    'model': os.environ['MODEL_NAME'],
    'quantize': os.environ['QUANTIZE_MODEL'] == 'true'
}
model_class = ModelInference(args)

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
async def run_health_check():
    return {'res': True}
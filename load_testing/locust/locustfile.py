from locust import HttpUser, TaskSet, task
import pandas as pd
from locust import events
import os

data = pd.read_csv('./data_samples.csv', names=['index', 'text'])
data['nb_words'] = data['text'].apply(lambda x: len(x.split(' ')))

max_nb_words = int(os.environ['LOCUST_MAX_NB_WORDS'])
min_nb_words = int(os.environ['LOCUST_MIN_NB_WORDS'])
data = data.loc[(data['nb_words'] >= min_nb_words) & (data['nb_words'] <= max_nb_words)]\
           .reset_index(drop=True)

class UserBehavior(HttpUser):
    @task(1)
    def request_prediction(self):
        message = data['text'].sample(1).iloc[0]
        self.client.post("/prediction", json={'text': message})
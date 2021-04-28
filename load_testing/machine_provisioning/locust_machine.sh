#!/bin/bash
PROJECT_ID=$1

ZONE=us-central1-a
MACHINE_TYPE=e2-standard-4

gcloud compute instances create benchmarking-nlp-inference-locust \
    --machine-type=$MACHINE_TYPE \
    --metadata startup-script='#! /bin/bash
    sudo apt-get update
    sudo apt-get --assume-yes install python3 python3-pip
    ' \
    --zone $ZONE \
    --project $PROJECT_ID

gcloud compute scp ../locust/data_samples.csv locust@benchmarking-nlp-inference-locust:~ --zone $ZONE
gcloud compute scp ../locust/requirements.txt locust@benchmarking-nlp-inference-locust:~ --zone $ZONE
gcloud compute scp ../locust/locustfile.py locust@benchmarking-nlp-inference-locust:~ --zone $ZONE
gcloud compute scp ../locust/run_load_test.sh locust@benchmarking-nlp-inference-locust:~ --zone $ZONE

gcloud compute ssh --zone $ZONE locust@benchmarking-nlp-inference-locust -- 'pip3 install -r requirements.txt'
gcloud compute ssh --zone $ZONE locust@benchmarking-nlp-inference-locust
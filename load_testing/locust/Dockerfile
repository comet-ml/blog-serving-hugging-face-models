FROM python:3.8.9-slim-buster

WORKDIR /locust
COPY requirements.txt requirements.txt
COPY locustfile.py locustfile.py
COPY data_samples.csv data_samples.csv
COPY run_load_test.sh run_load_test.sh

RUN pip install -r requirements.txt

#ENTRYPOINT exec echo "ran"
FROM python:3.8.9-slim-buster

WORKDIR /app
COPY requirements.txt requirements.txt
COPY main.py main.py

RUN pip install -r requirements.txt

EXPOSE 8000
ENV GUNICORN_CMD_ARGS="--bind=0.0.0.0:8000 -k uvicorn.workers.UvicornWorker --timeout 1000"

ENTRYPOINT exec gunicorn main:app --workers $NB_WORKERS
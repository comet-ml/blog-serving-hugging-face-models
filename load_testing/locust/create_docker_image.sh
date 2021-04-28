PROJECT_ID=$1
IMAGE_NAME=benchmarking-nlp-inference-locust

gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME --project $PROJECT_ID
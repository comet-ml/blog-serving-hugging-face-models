#!/bin/bash
PROJECT_ID=$1
ZONE=us-central1-a

# Util function
waitforurl() {
    attempt_counter=0
    max_attempts=100
    
    until $(curl --output /dev/null --silent --head --fail -X GET $1); do
        if [ ${attempt_counter} -eq ${max_attempts} ];then
        echo "Max attempts reached"
        exit 1
        fi

        printf '.'
        attempt_counter=$(($attempt_counter+1))
        sleep 5
    done
}

# Create firewall rule so we can access instance from public internet
gcloud compute firewall-rules create benchmarking-nlp-inference-allow-http-8000 \
        --allow tcp:8000 \
        --source-ranges 0.0.0.0/0 \
        --target-tags benchmarking-nlp-inference-allow-http-8000 \
        --description "Allow port 8000 access to benchmarking_nlp_inference" \
        --project $PROJECT_ID

# Start container for baseline model
MACHINE_TYPE=e2-standard-4
CONTAINER_ENV="NB_WORKERS=1"
INSTANCE_NAME=benchmarking-nlp-inference-baseline

gcloud compute instances create-with-container benchmarking-nlp-inference-baseline \
    --container-image gcr.io/$PROJECT_ID/benchmarking-nlp-inference-baseline \
    --container-env=$CONTAINER_ENV \
    --machine-type=$MACHINE_TYPE \
    --zone $ZONE \
    --tags benchmarking-nlp-inference-allow-http-8000 \
    --project $PROJECT_ID

# Wait for machine to start before exiting
IP_ADDRESS=$(gcloud compute instances describe $INSTANCE_NAME --zone $ZONE --project $PROJECT_ID --format='value[](networkInterfaces.accessConfigs[0].natIP)')
waitforurl http://$IP_ADDRESS:8000

echo "-------------------------"
echo "Baseline inference service is ready to tested:"
echo "* IP = http://$IP_ADDRESS:8000"

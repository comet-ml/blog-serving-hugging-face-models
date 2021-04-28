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
    --description "Allow port 8000 access to benchmarking-nlp-inference-allow-http-8000" \
    --project $PROJECT_ID

function start_container_instance() {
    MACHINE_TYPE=e2-standard-4
    MODEL_NAME=$1
    QUANTIZE_MODEL=$2
    NB_WORKERS=$3
    
    MODEL_LOWER_CASE=$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]')
    INSTANCE_NAME=benchmarking-nlp-inference-$NB_WORKERS-$MODEL_LOWER_CASE-$QUANTIZE_MODEL-$MACHINE_TYPE
    ZONE=us-central1-a
    
    CONTAINER_ENV="NB_WORKERS=$NB_WORKERS,MODEL_NAME=$MODEL_NAME,QUANTIZE_MODEL=$QUANTIZE_MODEL"
    gcloud compute instances create-with-container $INSTANCE_NAME \
        --container-image gcr.io/$PROJECT_ID/benchmarking-nlp-inference-model-optimised \
        --container-env=$CONTAINER_ENV \
        --machine-type=$MACHINE_TYPE \
        --zone $ZONE \
        --tags benchmarking-nlp-inference-allow-http-8000 \
        --project $PROJECT_ID

    IP_ADDRESS=$(gcloud compute instances describe $INSTANCE_NAME --zone $ZONE --project $PROJECT_ID --format='value[](networkInterfaces.accessConfigs[0].natIP)')
    waitforurl http://$IP_ADDRESS:8000

    echo "-------------------------"
    echo "Model is ready to be tested:"
    echo "* Model = $MODEL_NAME"
    echo "* Quantization = $QUANTIZE_MODEL"
    echo "* Number workers = $NB_WORKERS"
    echo "* IP = http://$IP_ADDRESS:8000"
}

# Test different number of workers
start_container_instance $2 $3 $4
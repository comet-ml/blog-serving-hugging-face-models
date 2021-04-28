function build_base_image() {
    PROJECT_ID=$1
    INFERENCE_SERVER=$2

    cd $INFERENCE_SERVER
    
    # Create CPU image
    IMAGE_NAME=benchmarking-nlp-inference-$INFERENCE_SERVER
    gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME --project $PROJECT_ID

    cd ..
}

build_base_image $1 baseline &
build_base_image $1 model-optimised &
build_base_image $1 model-hardware-optimised &

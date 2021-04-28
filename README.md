# How to easily and efficiently deploy Hugging Face models
Code repository to reproduce the benchmarking results presented [here](https://www.comet.ml/site/how-to-10x-throughput-when-serving-hugging-face-models-without-a-gpu/)

The repo is broken down into 2 sections:
* python-api: The Python inference services that we tested:
  * baseline: Baseline inference service using default parameters - This is **not** optimized
  * model-hardware-optimized: Optimized inference service for DistilBert - This is the most optimized inference service
  * model-optimized: Optimized inference service that support both Bert and DistilBert models as well as optional quantization
* load-testing: Utilities to run performance benchmarks

## How to run the benchmarks
Given all our benchmarks are run on GCP, you will need to have a Google Cloud project.

Running the benchmarks is done in three steps:
1. Create the docker images for each Python API:
```bash
cd python-api
sh create_docker_images.sh <GOOGLE_PROJECT_ID>
```
2. Deploy a virtual machine for the python api we wish to test:
```bash
cd load_testing/machine_provisioning

sh baseline_benchmark.sh GOOGLE_PROJECT_ID>
```
3. We will now create a virtual machine from which to run our load testing software:
```bash
cd load_testing/machine_provisioning
sh locust_machine.sh <GOOGLE_PROJECT_ID>
```
4. The last part of the script run in step 3 is to connect via ssh to the virtual machine. In this terminal we can run our load testing script:
```bash
cd /locust
sh run_load_test.sh <IP ADRESS printed in step 2> <NB_CONCURRENT_USERS>
```

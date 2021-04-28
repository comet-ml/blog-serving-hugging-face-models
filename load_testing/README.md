## Running benchmarks

1. Start instances using:
  1. `sh baseline_benchmark.sh`
  2. `sh model_optimised_benchmark.sh`
  3. `sh baseline_benchmark.sh`
2. Start locust using: `env LOCUST_MIN_NB_WORDS=45 LOCUST_MAX_NB_WORDS=55  locust --locustfile ./locust/locustfile.py`
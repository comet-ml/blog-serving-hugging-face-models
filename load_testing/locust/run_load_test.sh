IP_ADDRESS=$1
NB_CONCURRENT_USERS=$2

env LOCUST_MIN_NB_WORDS=45 LOCUST_MAX_NB_WORDS=55  locust --headless --locustfile ./locustfile.py --host=http://$IP_ADDRESS:8000 \
           --users $NB_CONCURRENT_USERS --spawn-rate 1 --run-time 30s --reset-stats --loglevel ERROR \
           --stop-timeout 999
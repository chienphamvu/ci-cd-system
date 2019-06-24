EXECUTOR_PER_NODE=2

JOB_QUEUE_COUNT=$(curl --user admin:admin http://localhost:8080/queue/api/xml > output.xml | grep -o "<task" | wc -l)
CURRENT_NODE_COUNT=$(curl --user admin:admin http://localhost:8080/computer/api/json | jq '.computer | length')

if [ -n "$TARGET_NB_NODE" ]; then
    
fi
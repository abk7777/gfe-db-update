#!/bin/bash

ROOT=$(dirname $(dirname "$0"))
BIN_DIR=$ROOT/bin

end=$((SECONDS+60))

# Check for SQS messages containing environment variables
while [ $SECONDS -lt $end]; do

    # Poll SQS every 5 seconds and save message
    echo "Checking for message..."
    aws sqs receive-message \
        --queue-url https://sqs.us-east-1.amazonaws.com/531868584498/gfe-db-test | \
            jq -r > sqs-message.json
    sleep 5

    # If the response has content, exit the loop
    if [ -s sqs-message.json ]; then
        echo "Message found."

        export RELEASES=$(cat sqs-message.json | jq '.Messages[].Body | fromjson | .release')
        export ALIGN=$(cat sqs-message.json | jq '.Messages[].Body | fromjson | .align')
        export KIR=$(cat sqs-message.json | jq '.Messages[].Body | fromjson | .kir')
        export MEM_PROFILE=$(cat sqs-message.json | jq '.Messages[].Body | fromjson | .mem_profile')

        sh $BIN_DIR/build.sh 100

        break
    fi

done

echo "Operation timed out"

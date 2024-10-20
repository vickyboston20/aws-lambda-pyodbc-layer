#!/bin/bash

# Check if msodbc_version is passed as an argument
if [ -z "$1" ]; then
    echo "Error: msodbc_version argument is required."
    exit 1
fi

MSODBC_VERSION=$1

# Store the curl output and HTTP status code
RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d "{\"msodbc_version\": \"$MSODBC_VERSION\"}")

# Check if the response status code is 200 (success)
if [ "$RESPONSE" -ne 200 ]; then
    echo "Lambda function failed with status code $RESPONSE"
    cat response.txt
    exit 1
else
    # Check the contents of response.txt for the error message
    if grep -q '"statusCode": 500' response.txt; then
        echo "Lambda function failed internally with error:"
        cat response.txt
        exit 1
    else
        echo "Lambda function succeeded!"
        cat response.txt
    fi
fi

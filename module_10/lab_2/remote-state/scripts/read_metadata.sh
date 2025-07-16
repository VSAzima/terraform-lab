#!/bin/bash

bucket="$1"
key="$2"
region="$3"

# Get raw state
raw_json=$(aws s3 cp "s3://$bucket/$key" - --region "$region")

# Extract fields and ensure they're strings
version=$(echo "$raw_json" | jq -r '.version | tostring')
serial=$(echo "$raw_json" | jq -r '.serial | tostring')

# Output JSON with only string values
echo "{\"version\": \"$version\", \"serial\": \"$serial\"}"

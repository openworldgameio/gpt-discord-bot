#!/bin/bash
## This script is provided as an example for how to build, deploy and start
## this Discord Bot on Google "Cloud Run"

## Get the current date and time and region to run it on...
ymdt=$(date "+%Y-%m-%d_%H-%M")
## Setup a logfile name...
log_file="logs/${GCP_APP_NAME}_${ymdt}.log"
echo "Start time: $ymdt" | tee $log_file

## Build a new version...
gcloud builds submit \
  --tag gcr.io/${GCP_PROJECT}/${GCP_APP_NAME} 2>&1 | tee -a $log_file
## Deploy the new version...
gcloud run deploy ${GCP_APP_NAME} \
  --image gcr.io/${GCP_PROJECT}/${GCP_APP_NAME} \
  --platform managed \
  --region ${GCP_REGION} \
  --no-cpu-throttling 2>&1 | tee -a $log_file

## Get proper URL
GCP_APP_URL=$(gcloud run services list --platform=managed --region=${GCP_REGION} \
  --filter="status.address.url ~ ${GCP_APP_NAME}-" \
  --format="value(status.address.url)")
## Setup a scheduler to call the URL every minute, to keep it alive
gcloud scheduler jobs create http GET-gpt-discord-bot-ai-assistant \
  --schedule="1 * * * *" \
  --uri="${GCP_APP_URL}" \
  --http-method GET | tee -a $log_file

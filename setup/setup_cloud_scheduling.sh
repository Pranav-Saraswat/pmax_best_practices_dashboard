#!/bin/bash

COLOR='\033[0;36m'
service_account_name="pmaxdash-ext-service"
service_account_email="$service_account_name@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
topic_name="pmaxdash-schedules"
subscription="pmaxdash-trigger-sub"

echo -n -e "${COLOR}Creating Service Account..."

gcloud iam service-accounts create $service_account_name --display-name $service_account_name 
gcloud run services add-iam-policy-binding pmaxdash \
   --member=serviceAccount:$service_account_email \
   --role=roles/run.invoker \
   --region=${GOOGLE_CLOUD_REGION}
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
     --member=serviceAccount:$service_account_email\
     --role=roles/iam.serviceAccountTokenCreator

echo -n -e "${COLOR}Creating PubSub scheduler..."

gcloud pubsub topics create $topic_name
gcloud scheduler jobs create pubsub daily-data-refresh --location=${GOOGLE_CLOUD_REGION} --schedule="0 4 * * *" --topic=$topic_name --attributes="TRIGGER=TRUE" --message-body="Triggering queries run" --time-zone="Israel"
# Configure the push subscription
gcloud pubsub subscriptions create $subscription \
 --topic=$topic_name \
 --ack-deadline=600 \
 --push-endpoint=${SERVICE_URL}/run-queries \
 --push-auth-service-account=$service_account_email \


echo -n -e "${COLOR}Extending service timeout limit..."
gcloud run services update pmaxdash --timeout=3600 --region=${GOOGLE_CLOUD_REGION}
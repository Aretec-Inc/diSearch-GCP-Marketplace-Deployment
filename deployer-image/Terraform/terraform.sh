#!/bin/bash
# ██████  ██ ███████ ███████  █████  ██████   ██████ ██   ██
# ██   ██ ██ ██      ██      ██   ██ ██   ██ ██      ██   ██
# ██   ██ ██ ███████ █████   ███████ ██████  ██      ███████
# ██   ██ ██      ██ ██      ██   ██ ██   ██ ██      ██   ██
# ██████  ██ ███████ ███████ ██   ██ ██   ██  ██████ ██   ██



#  _____           _           _      _____             __ _        __      __        _       _     _
# |  __ \         (_)         | |    / ____|           / _(_)       \ \    / /       (_)     | |   | |
# | |__) | __ ___  _  ___  ___| |_  | |     ___  _ __ | |_ _  __ _   \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___
# |  ___/ '__/ _ \| |/ _ \/ __| __| | |    / _ \| '_ \|  _| |/ _` |   \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
# | |   | | | (_) | |  __/ (__| |_  | |___| (_) | | | | | | | (_| |    \  / (_| | |  | | (_| | |_) | |  __/\__ \
# |_|   |_|  \___/| |\___|\___|\__|  \_____\___/|_| |_|_| |_|\__, |     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#                _/ |                                         __/ |
#               |__/                                         |___/


echo "Project ID is $PROJECT_ID"
#PROJECT_ID="world-learning-400909"
echo "Project Number is $PROJECT_NUMBER"
echo "Default Owner Email is $DEFAULT_OWNER_EMAIL"
echo "Region is $REGION"
echo "Location is $LOCATION"
echo "VPC Name is $VPC_NAME"
echo "Subnet Name is $SUBNET_NAME"
echo "GKE Subnet Name is $GKE_SUBNET_NAME"
echo "Database Instance Disk Size is $DB_INSTANCE_DISK_SIZE"
echo "Database Username is $DB_USERNAME"
echo "Database Password is $DB_PASSWORD"
echo "Cloud Run Service Name is $CLOUD_RUN_SERVICE_NAME"
echo "GKE Cluster Name is $GKE_CLUSTER_NAME"
echo "GKE Nodes Machine Type is $GKE_NODES_MACHINE_TYPE"
echo "Storage Bucket Name is $STORAGE_BUCKET_NAME"
echo "Stripe Secret Key is $STRIPE_SECRET_KEY"
echo "Aretc Admin Password is $ARETEC_ADMIN"
echo "Logs URL is $LOGS_URL"
echo "OpenAI Key is $OPENAI_KEY"
echo "OpenAI API Key is $OPENAI_API_KEY"
APP_NAME="disearch"
SERVICE_ACCOUNT="gke-sa@$PROJECT_ID.iam.gserviceaccount.com"
OPEN_AI_KEY=""





#                _   _                _   _           _   _
#     /\        | | | |              | | (_)         | | (_)
#    /  \  _   _| |_| |__   ___ _ __ | |_ _  ___ __ _| |_ _  ___  _ __
#   / /\ \| | | | __| '_ \ / _ \ '_ \| __| |/ __/ _` | __| |/ _ \| '_ \
#  / ____ \ |_| | |_| | | |  __/ | | | |_| | (_| (_| | |_| | (_) | | | |
# /_/    \_\__,_|\__|_| |_|\___|_| |_|\__|_|\___\__,_|\__|_|\___/|_| |_|
# Authenticating using GCP Service Account Key
echo $SERVICE_ACCOUNT_KEY > secret.json
gcloud auth activate-service-account --key-file=./secret.json
gcloud config set project $PROJECT_ID









#  _______                   __                        _____ _        _
# |__   __|                 / _|                      / ____| |      | |
#    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___   | (___ | |_ __ _| |_ ___
#    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \   \___ \| __/ _` | __/ _ \
#    | |  __/ |  | | | (_| | || (_) | |  | | | | | |  ____) | || (_| | ||  __/
#    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_| |_____/ \__\__,_|\__\___|

# Creating Bucket for Storing Terraform State. If exist then skip to next step.
TF_BUCKET_SECRET_NAME="terraform_state"
EXISTING_TF_SECRET=$(gcloud secrets list --filter="name:$TF_BUCKET_SECRET_NAME" --format="value(name)")

if [ -n "$EXISTING_TF_SECRET" ]; then
  echo "Secret '$TF_BUCKET_SECRET_NAME' already exists. Skipping bucket creation."
  # Retrieve the bucket name from the existing secret
  TF_STATE_BUCKET_NAME=$(gcloud secrets versions access latest --secret="$TF_BUCKET_SECRET_NAME")
  echo "Bucket name retrieved from secret: $TF_STATE_BUCKET_NAME"
else
  # Generate a random string
  RANDOM_STRING=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)

  # Combine the base bucket name with the random string
  TF_STATE_BUCKET_NAME="terraform-state-$RANDOM_STRING"

  # Create the bucket
  echo "Creating bucket: gs://$TF_STATE_BUCKET_NAME"
  gcloud storage buckets create gs://$TF_STATE_BUCKET_NAME --location=$REGION

  # Create the secret and save the bucket name in it
  echo "Creating secret '$TF_BUCKET_SECRET_NAME' and saving the bucket name in it."
  echo -n "$TF_STATE_BUCKET_NAME" | gcloud secrets create $TF_BUCKET_SECRET_NAME --data-file=-

  # Add a new version of the secret with the bucket name
  echo -n "$TF_STATE_BUCKET_NAME" | gcloud secrets versions add $TF_BUCKET_SECRET_NAME --data-file=-
fi

sed -i "s/TF_BACKEND_BUCKET_NAME/$TF_STATE_BUCKET_NAME/g" main.tf
echo "Done."








#  _______                   __                                            _
# |__   __|                 / _|                         /\               | |
#    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___      /  \   _ __  _ __ | |_   _
#    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \    / /\ \ | '_ \| '_ \| | | | |
#    | |  __/ |  | | | (_| | || (_) | |  | | | | | |  / ____ \| |_) | |_) | | |_| |
#    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_| /_/    \_\ .__/| .__/|_|\__, |
#                                                             | |   | |       __/ |
#                                                             |_|   |_|      |___/

# Apply Terraform configuration
terraform init
terraform plan \
  -var="projectName=$PROJECT_ID" \
  -var="region=$REGION" \
  -var="location=$LOCATION" \
  -var="vpc_name=$VPC_NAME" \
  -var="subnet_name=$SUBNET_NAME" \
  -var="gke_subnet_name=$GKE_SUBNET_NAME" \
  -var="db_instance_disk_size=$DB_INSTANCE_DISK_SIZE" \
  -var="db_username=$DB_USERNAME" \
  -var="db_password=$DB_PASSWORD" \
  -var="cloud_run_service_name=$CLOUD_RUN_SERVICE_NAME" \
  -var="gke_cluster_name=$GKE_CLUSTER_NAME" \
  -var="gke_nodes_machine_type=$GKE_NODES_MACHINE_TYPE" \
  -var="storage_bucket_name=$STORAGE_BUCKET_NAME" \
  -var="STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" \
  -var="aretec_admin=$ARETEC_ADMIN" \
  -var="LOGS_URL=$LOGS_URL" \
  -var="OPENAI_KEY=$OPENAI_KEY" \
  -var="OPENAI_API_KEY=$OPENAI_API_KEY" \

terraform apply \
  -var="projectName=$PROJECT_ID" \
  -var="region=$REGION" \
  -var="location=$LOCATION" \
  -var="vpc_name=$VPC_NAME" \
  -var="subnet_name=$SUBNET_NAME" \
  -var="gke_subnet_name=$GKE_SUBNET_NAME" \
  -var="db_instance_disk_size=$DB_INSTANCE_DISK_SIZE" \
  -var="db_username=$DB_USERNAME" \
  -var="db_password=$DB_PASSWORD" \
  -var="cloud_run_service_name=$CLOUD_RUN_SERVICE_NAME" \
  -var="gke_cluster_name=$GKE_CLUSTER_NAME" \
  -var="gke_nodes_machine_type=$GKE_NODES_MACHINE_TYPE" \
  -var="storage_bucket_name=$STORAGE_BUCKET_NAME" \
  -var="STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" \
  -var="aretec_admin=$ARETEC_ADMIN" \
  -var="LOGS_URL=$LOGS_URL" \
  -var="OPENAI_KEY=$OPENAI_KEY" \
  -var="OPENAI_API_KEY=$OPENAI_API_KEY" \
  -auto-approve

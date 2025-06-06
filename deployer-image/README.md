This guide provides instructions on how to set up a complete project in GCP.

## Step 1: Authenticate with Google Cloud:
Use the following command to authenticate your local environment with your Google Cloud account:

    gcloud auth login

This command will open a web browser where you can log in with your Google account.

After authentication, set your active Google Cloud project by running:

    gcloud config set project YOUR_GCP_PROJECT_ID

Replace YOUR_GCP_PROJECT_ID with your actual Google Cloud project ID.  

## Creating and Configuring the Service Account using gcloud commands.

## Step 2: Create the Service Account

Use the following gcloud command to create a new service account:

    gcloud iam service-accounts create terraform \
    --display-name="terraform"
    
## Step 3: Assign IAM Role Permissions

Assign the required IAM roles to the service account with the following command:     
    
    gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
      --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
      --role="roles/compute.admin"

      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/compute.storageAdmin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/editor"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/container.admin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/monitoring.viewer"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/secretmanager.admin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/secretmanager.secretAccessor"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/iam.securityAdmin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/vpcaccess.admin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/iam.serviceAccountAdmin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.admin"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/iam.workloadIdentityUser"
    
      gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
        --member="serviceAccount:terraform@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com" \
        --role="roles/servicenetworking.networksAdmin"


## Step 4: Generate the Service Account Key
  
Generate the service account key and save it to a JSON file:
    
    gcloud iam service-accounts keys create ./secret.json \
    --iam-account=terraform@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com

After generating the new key, activate the service account using:

    gcloud auth activate-service-account --key-file=secret.json

## Step 5: Create a Bucket for Storing the Terraform State File

    gcloud storage buckets create gs://NAME-OF-YOUR-GCP-BUCKET --location=us-central1

Remember, the bucket name must be globally unique. After creating the bucket, replace the bucket name in the terraform backend section within the main.tf file.

## Step 6: Creating Infrastructure in GCP using Terraform

    terraform init
    terraform plan -var="projectName=YOUR_GCP_PROJECT_ID"
    terraform apply -var="projectName=YOUR_GCP_PROJECT_ID" -auto-approve
 
## Step 7: Workload Identity setup


    Connecting the cluster 
    
    gcloud container clusters get-credentials disearch-cluster --zone us-central1-c --project YOUR_GCP_PROJECT_ID
     
    kubectl create serviceaccount gke-sa --namespace=default

    gcloud iam service-accounts add-iam-policy-binding gke-sa@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$YOUR_GCP_PROJECT_ID.svc.id.goog[default/gke-sa]"
    
    kubectl annotate serviceaccount gke-sa \
    --namespace default \
    iam.gke.io/gcp-service-account=gke-sa@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com
    
## Step 8: Fetch and saving the private IP address of the Cloud SQL instance to GCP secrets

    gcloud secrets versions add DB_HOST --data-file=<(gcloud sql instances describe disearch-db --format="json(ipAddresses)" | jq -r '.ipAddresses[] | select(.type == "PRIVATE") | .ipAddress')

## Step 9: Creating Postgres Connection String 

    ENCODED_CONN_STRING=$(echo -n "postgresql://postgres:$(gcloud secrets versions access latest --secret=DB_PASSWORD)@$(gcloud secrets versions access latest --secret=DB_HOST)/postgres" | base64 -w 0)

Use below commands for Verificaiton

    echo "ENCODED_CONN_STRING: $(echo "$ENCODED_CONN_STRING" | base64 --decode)"

## Step 10: Cloud Function Deployments

    BUCKET_NAME=$(gcloud secrets versions access latest --secret="GCP_BUCKET") && echo "Bucket name: $BUCKET_NAME"

Clone the GitHub repository. 

Email at aareez.asif@aretecinc.com to get the authentication token for pulling the cloud functions from the repository.

    git clone https://PASTE_AUTHENTICATION_TOKEN_HERE@github.com/Aretec-Inc/uploader-trigger-cf.git
    git clone https://PASTE_AUTHENTICATION_TOKEN_HERE@github.com/Aretec-Inc/document-status-cf.git
    git clone https://PASTE_AUTHENTICATION_TOKEN_HERE@github.com/Aretec-Inc/image-process-cf.git
    git clone https://PASTE_AUTHENTICATION_TOKEN_HERE@github.com/Aretec-Inc/metadata-extractor-cf.git
    git clone https://PASTE_AUTHENTICATION_TOKEN_HERE@github.com/Aretec-Inc/pdf-convert-cf.git

Email at aareez.asif@aretecinc.com to get the authentication token for pulling the cloud functions from the repository.

Appling Policy
    
    GCS_SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p "YOUR_GCP_PROJECT_NUMBER") && echo "GCS_SERVICE_ACCOUNT: $GCS_SERVICE_ACCOUNT"

    gcloud projects add-iam-policy-binding "YOUR_GCP_PROJECT_ID" \
      --member serviceAccount:$GCS_SERVICE_ACCOUNT \
      --role roles/pubsub.publisher

Cloud Functions

Deploying Cloud Function uploader-trigger

    echo "Deploying uploader-trigger"
    cd uploader-trigger-cf
    git checkout deployment
    gcloud functions deploy uploader-trigger \
      --runtime python39 \
      --entry-point main_func \
      --set-env-vars=LOG_EXECUTION_ID=true \
      --set-secrets=bucket=projects/$PROJECT_ID/secrets/GCP_BUCKET:latest,project_id=projects/"YOUR_GCP_PROJECT_ID"/secrets/project_id:latest \
      --service-account gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com \
      --serve-all-traffic-latest-revision \
      --vpc-connector disearch-vpc-connector \
      --trigger-bucket $BUCKET_NAME \
      --region us-central1 \
      --gen2 \
      --quiet
    cd ..
    
Deploying Cloud Function document-status

    echo "Deploying document-status"
    cd document-status-cf
    git checkout deployment
    gcloud functions deploy document-status \
      --runtime python39 \
      --trigger-http \
      --entry-point main_func \
      --set-secrets 'DB_HOST=DB_HOST:latest,DB_USER=DB_USER:latest,DB_PASSWORD=DB_PASSWORD:latest' \
      --service-account  gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com \
      --serve-all-traffic-latest-revision \
      --vpc-connector disearch-vpc-connector \
      --region us-central1 \
      --gen2 \
      --quiet
    cd ..

Deploying Cloud Function image-processing

    echo "Deploying image-processing"
    cd image-process-cf
    git checkout deployment
    gcloud functions deploy image-processing \
      --runtime python39 \
      --entry-point main_func \
      --service-account  gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com \
      --set-env-vars=SCHEMA=disearch_search,LOG_EXECUTION_ID=true \
      --set-secrets 'LOG_INDEX=LOG_INDEX:latest,LOGS_URL=LOGS_URL:latest,gpt_key=OPENAI_API_KEY:latest' \                  ## remember to give the open api key in terraform variable.tf
      --vpc-connector disearch-vpc-connector \
      --serve-all-traffic-latest-revision \
      --trigger-http \
      --gen2 \
      --region us-central1 \
      --memory 2G
    cd ..  

Deploying Cloud Function Metadata Extractor
    
    echo "Deploying Metadata Extractor"
    cd metadata-extractor-cf
    git checkout deployment
    gcloud functions deploy update_metadata_ingested_document \
      --runtime python39 \
      --trigger-http \
      --entry-point main_func \
      --set-env-vars=LOG_EXECUTION_ID=true \
      --set-secrets=project_id=projects/$PROJECT_ID/secrets/project_id:latest \
      --service-account gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com \
      --vpc-connector disearch-vpc-connector --region us-central1 --serve-all-traffic-latest-revision --gen2 --memory 1G
    cd ..



## Step 11: RUN the deployer image from GCP Market place for deploying the Applications services.


  #### Adding Passwords to values.yaml Files

  ETCD Chart:

    - Add the password at line #121 in the values.yaml file.
    - Encode the password in Base64 and add it to the vertexai values.yaml file at line #21.

  Redis Chart:

    - Add the password at line #146 in the values.yaml file.

  #### Required Variables for Deployer Image Deployment

  When deploying the deployer image from Google Cloud Marketplace, you need to provide following variables. 

  - GCP project id
  - GCP Cloud SQL Db Connection String in Base64 Encoded format
  - GKE kube API Server URL in Base64 Encoded format
  - Client Email Address
  - DB User
  - DB Password
  - DB Host
  - GCP Bucket Name created by terraform
  - Cloudfunction URLs Name:
    - document-status
    - image-processing
    - update_metadata_ingested_document

You can use the following commands to obtain the required variable information. Add this information as **default values** under the **properties** section in the **schema.yaml** file and include it in the corresponding **values.yaml** file, as described below.

- Fetch the project ID and place it in the vertexai and disearch values.yaml file at line #4.

- Use the following command to create a connection string and encode it in Base64. Place it in vertexai values.yaml at line #12 under the variable **cloudSqlDbConn**.

    Creating Postgres Connection String

      ENCODED_CONN_STRING=$(echo -n "postgresql://postgres:$(gcloud secrets versions access latest --secret=DB_PASSWORD)@$(gcloud secrets versions access latest --secret=DB_HOST)/postgres" | base64 -w 0)
    
    Use below commands for Verificaiton

      echo "$ENCODED_CONN_STRING"

      echo "ENCODED_CONN_STRING: $(echo "$ENCODED_CONN_STRING" | base64 --decode)"

- Fetch the private endpoint of the cluster and encode it in Base64. Place it in vertexai values.yaml at line #18 under the variable **k8sApiServerUrl**.

      Fetch private endpoint of Cluster

        echo "INTERNAL_ENDPOINT: $(echo -n "https://$(gcloud container clusters describe disearch-cluster --zone us-central1-c --format="get(privateClusterConfig.privateEndpoint)")" | base64)"
      
      Decode the base64 encoded endpoint for verfication

        echo <INTERNAL_ENDPOINT_ENCODED_VALUE> | base64 --decode

- Place the client website URL in the disearch values.yaml file at line #6 under the variable **allowedOrigin**.
- Place the client email address in the disearch values.yaml file at line #7 under the variable **authEmail**.

- DB User: Place at line #8 in disearch values.yaml file..

    gcloud secrets versions access latest --secret=**DB_USER**

- DB Password: Place at line #9 in disearch values.yaml file..

    gcloud secrets versions access latest --secret=**DB_PASSWORD**

- DB Host: Place at line #11 in disearch values.yaml file.

    gcloud secrets versions access latest --secret=**DB_HOST**

- GCP Bucket: Place at line #10 in disearch values.yaml file

    gcloud secrets versions access latest --secret=**GCP_BUCKET**

- Fetch Cloudfunction URLs of service document-status and place this in vertexai values.yaml file at line 35 under variable **statusCloudFn**.

    gcloud functions describe document-status --region=us-central1 --format="value(url)"

- Get Cloudfunction URLs of service image-processing and place this in vertexai values.yaml file at line 36 under variable **imageSummaryCloudFn**.

    gcloud functions describe image-processing --region=us-central1 --format="value(url)"

- Get Cloudfunction URLs of service update_metadata and place this in vertexai values.yaml file at line 37 under variable **updateMetadataFn**.

    gcloud functions describe update_metadata_ingested_document --region=us-central1 --format="value(url)"

Once completed, build the Dockerfile to create a Docker image and push it to a public repository. After that, you can deploy the deployer image from the GCP Marketplace.

## Step 12: Updating Cloudfunction URL's in GCP Secrets

      gcloud secrets versions add status_cloud_fn --data-file=<(echo -n "$(gcloud functions describe document-status --region=us-central1 --format="value(url)")") --project="YOUR_GCP_PROJECT_ID"

      gcloud secrets versions add image_summary_cloud_fn --data-file=<(echo -n "$(gcloud functions describe image-processing --region=us-central1 --format="value(url)")") --project="YOUR_GCP_PROJECT_ID"
          
      gcloud secrets versions add metadata_cloud_fn --data-file=<(echo -n "$(gcloud functions describe update_metadata_ingested_document --region=us-central1 --format="value(url)")") --project="YOUR_GCP_PROJECT_ID"


## Step 13: Creating Pubsub and subscriptions

Creating and listing pubsub topic

    gcloud pubsub topics create file-process-topic
    gcloud pubsub topics create eventarc-us-central1-uploader-trigger-241194-023 
    gcloud pubsub topics create image-topic
    gcloud pubsub topics create metadata-topic
    gcloud pubsub topics create pdf-convert-topic
    gcloud pubsub topics create dead-letter-topic
    gcloud pubsub topics list

Creating Pubsub Subscriptions

    gcloud pubsub subscriptions create file-process-subscription \
        --topic=file-process-topic \
        --message-retention-duration=7d \
        --expiration-period=31d \
        --ack-deadline=600

    gcloud pubsub subscriptions create eventarc-us-central1-uploader-trigger-241194-sub-633 \
        --topic=eventarc-us-central1-uploader-trigger-241194-023 \
        --message-retention-duration=7d \
        --expiration-period=31d \
        --ack-deadline=600
    
    
    gcloud pubsub subscriptions create image-subscription \
        --topic=image-topic \
        --message-retention-duration=7d \
        --expiration-period=31d \
        --ack-deadline=600
    
    
    gcloud pubsub subscriptions create metadata-subscription \
        --topic=metadata-topic \
        --message-retention-duration=7d \
        --expiration-period=31d \
        --ack-deadline=600
    
    
    gcloud pubsub subscriptions create pdf-subscription \
        --topic=pdf-convert-topic \
        --message-retention-duration=7d \
        --expiration-period=31d \
        --ack-deadline=600
## Step 14: Fetching and updating GKE variables in GCP secrets

Connecting the cluster

    gcloud container clusters get-credentials disearch-cluster --zone us-central1-c --project "YOUR_GCP_PROJECT_ID"

    kubectl get service doc-chat-service -n keda -o=jsonpath='http://{.status.loadBalancer.ingress[0].ip}' | gcloud secrets versions add DOCUMENT_CHAT_URL --data-file=-
    
    kubectl get service vertex-ai-followup-service -n keda -o=jsonpath='http://{.status.loadBalancer.ingress[0].ip}' | gcloud secrets versions add vertexai_followup --data-file=-
    
    kubectl get service vertexai-citation-service -n keda -o=jsonpath='http://{.status.loadBalancer.ingress[0].ip}' | gcloud secrets versions add vertexai_citation --data-file=-
    
    kubectl get service vertexai-service -n keda -o=jsonpath='http://{.status.loadBalancer.ingress[0].ip}' | gcloud secrets versions add vertexai_python_url --data-file=-
    
    kubectl get service vertexai-summary-service -n keda -o=jsonpath='http://{.status.loadBalancer.ingress[0].ip}' | gcloud secrets versions add vertexai-summary --data-file=-
    
    kubectl get service pdflb -n keda -o=jsonpath='http://{.status.loadBalancer.ingress[0].ip}' | gcloud secrets versions add pdf_loadbalancer --data-file=-

## Step 15: Updating GCP Secret for Website URL

       echo -n "YOUR_WEBSITE_URL" | gcloud secrets versions add vertexai-referer --data-file=- --project=YOUR_GCP_PROJECT_ID

Make sure to add the Website URL here.

## Step 16: Replacing Values For Cors

    sed -i "s|REPLACE_WITH_WEBSITE_URL|"YOUR_WEBSITE_URL"|g" cors.json
    gsutil cors set cors.json gs://$BUCKET_NAME
    gsutil cors get gs://$BUCKET_NAME

## Step 17: applying Cloud Run

    gcloud run deploy file-upload-pubsub --image=gcr.io/aretecinc-public/disearch/file-upload-pubsub:1.0.8 --set-env-vars=batch_size=1,project_id="YOUR_GCP_PROJECT_ID"  --platform managed  --vpc-connector=projects/"YOUR_GCP_PROJECT_ID"/locations/us-central1/connectors/disearch-vpc-connector --set-secrets=vertexai_python_url=vertexai_python_url:latest,metadata_cloud_fn=metadata_cloud_fn:latest,image_summary_cloud_fn=image_summary_cloud_fn:latest,APP_VERSION=APP_VERSION:latest --region=us-central1 --project="YOUR_GCP_PROJECT_ID" --service-account=gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com --allow-unauthenticated --min-instances=1 --max-instances=2
    
    
    gcloud run deploy image-pubsub --image=gcr.io/aretecinc-public/disearch/image-pubsub:1.0.8 --set-env-vars=image_subscription_id=image-subscription,project_id="YOUR_GCP_PROJECT_ID",batch_size=1,project_id="YOUR_GCP_PROJECT_ID"  --platform managed  --vpc-connector=projects/"YOUR_GCP_PROJECT_ID"/locations/us-central1/connectors/disearch-vpc-connector --set-secrets=vertexai_python_url=vertexai_python_url:latest,metadata_cloud_fn=metadata_cloud_fn:latest,image_summary_cloud_fn=image_summary_cloud_fn:latest,APP_VERSION=APP_VERSION:latest --region=us-central1 --project="YOUR_GCP_PROJECT_ID" --service-account=gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com --allow-unauthenticated --min-instances=1 --max-instances=2
    
  
    gcloud run deploy metadata-pubsub --image=gcr.io/aretecinc-public/disearch/metadata-pubsub:1.0.8 --set-env-vars=project_id="YOUR_GCP_PROJECT_ID",batch_size=1 --platform managed  --vpc-connector=projects/"YOUR_GCP_PROJECT_ID"/locations/us-central1/connectors/disearch-vpc-connector --set-secrets=vertexai_python_url=vertexai_python_url:latest,metadata_cloud_fn=metadata_cloud_fn:latest,image_summary_cloud_fn=image_summary_cloud_fn:latest,APP_VERSION=APP_VERSION:latest --region=us-central1 --project="YOUR_GCP_PROJECT_ID" --service-account=gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com --allow-unauthenticated --min-instances=1 --max-instances=2
    
   
    gcloud run deploy pdf-convert-pubsub --image=gcr.io/aretecinc-public/disearch/pdf-convert-pubsub:1.0.8 --set-env-vars=batch_size=1,project_id="YOUR_GCP_PROJECT_ID" --platform managed  --vpc-connector=projects/"YOUR_GCP_PROJECT_ID"/locations/us-central1/connectors/disearch-vpc-connector --set-secrets=pdf_loadbalancer=pdf_loadbalancer:latest,APP_VERSION=APP_VERSION:latest --region=us-central1 --project="YOUR_GCP_PROJECT_ID" --service-account=gke-sa@"YOUR_GCP_PROJECT_ID".iam.gserviceaccount.com --allow-unauthenticated --min-instances=1 --max-instances=2
    
    

## Step 18: LLM

    echo "Adding LLM Models on Cloud SQL Instance"
    gcloud run jobs create llm-model-migration --image=$LLM_MODEL_IMPORT_ID \
      --vpc-connector=disearch-vpc-connector --set-cloudsql-instances=$PROJECT_ID:us-central1:disearch-db \
      --region=us-central1 --set-secrets=DB_HOST=DB_HOST:latest,DB_PASSWORD=DB_PASSWORD:latest \
      --project=$PROJECT_ID --service-account=terraform@$PROJECT_ID.iam.gserviceaccount.com

    gcloud run jobs execute llm-model-migration --region us-central1


## Step 19: Deploy DiSearch from GCP Marketplace

Once Step 18 is successfully completed, proceed to the GCP Marketplace and locate "DiSearch." After selecting it, provide the required details as follows:

- Microservices URLs  
- Database Credentials  
- Storage Bucket Name  
- CORS Allowed Origin for Bucket  
- Owner Email  
- Project ID  
- OpenAI API Key  
- Service Account Name  

After filling in the necessary information, deploy the solution.
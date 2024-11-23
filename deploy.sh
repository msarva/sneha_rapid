#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set variables
PROJECT_ID="ssneha123456"        # Replace with your Google Cloud project ID
IMAGE_NAME="pdf"                 # Replace with your Docker image name
TAG="latest"                     # Replace with your image tag, e.g., 'v1'
REGION="us-central1"             # Replace with your preferred region
SERVICE_NAME="pdf-service"       # Replace with your Cloud Run service name

# Authenticate with Google Cloud
echo "Authenticating with Google Cloud..."
gcloud auth login

# Set the active project
echo "Setting active project to $PROJECT_ID..."
gcloud config set project "$PROJECT_ID"

# Enable necessary Google Cloud APIs
echo "Enabling required APIs..."
gcloud services enable containerregistry.googleapis.com
gcloud services enable run.googleapis.com

# Build the Docker image
echo "Building Docker image..."
docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG .

# Tag the Docker image
echo "Tagging Docker image..."
docker tag gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG

# Push the Docker image to Google Container Registry
echo "Pushing Docker image to Google Container Registry..."
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG

# Deploy to Google Cloud Run
echo "Deploying to Google Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated

# Print success message
echo "Deployment completed successfully!"
echo "Your service is available at:"
gcloud run services describe $SERVICE_NAME --region $REGION --format "value(status.url)"

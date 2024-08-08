
# Set variables
ECR_REPO_NAME="bedrock-proxy-api"
REGION="us-west-2"  # Replace with your desired AWS region

# Check if the ECR repository exists
repo_exists=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION 2>&1)

# Check the exit status of the previous command
if [ $? -ne 0 ]; then
    if echo $repo_exists | grep -q "RepositoryNotFoundException"; then
        echo "Repository $ECR_REPO_NAME does not exist. Creating it now..."
        # aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION
        if [ $? -eq 0 ]; then
            echo "Repository $ECR_REPO_NAME created successfully."
        else
            echo "Failed to create repository $ECR_REPO_NAME. Exiting."
            exit 1
        fi
    else
        echo "An error occurred while checking the repository. Exiting."
        exit 1
    fi
else
    echo "Repository $ECR_REPO_NAME already exists. Skipping creation."
fi

# Run the push_to_ecr.sh script
echo "Running push_to_ecr.sh script..."
# ./push_to_ecr.sh

# if [ $? -eq 0 ]; then
#     echo "push_to_ecr.sh script executed successfully."
# else
#     echo "push_to_ecr.sh script failed to execute."
#     exit 1
# fi
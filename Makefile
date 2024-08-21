.PHONY: default cluster pod-identity-agent load-balancer-controller gw-pod-identity load-balancer-controller build deploy dev ingress compose-up compose-down

# Default target: run default steps
default: build deploy

cluster:
	@echo "\n========== Creating cluster... =========="
	eksctl deployment/k8s/create cluster.yaml

iam: pod-identity-agent gw-pod-identity

pod-identity-agent:
	@echo "Prequisits...."
	eksctl create addon --cluster br-gw-demo --name eks-pod-identity-agent

gw-pod-identity:
	@echo "\n========== Configuring EKS Pod Identity for the gateway =========="
	eksctl create podidentityassociation \
    --cluster br-gw-demo \
    --namespace bedrock-proxy-api \
    --service-account-name bedrock-proxy-api \
    --permission-policy-arns="arn:aws:iam::aws:policy/AmazonBedrockFullAccess"

load-balancer-controller:
	@echo "\n========== Setting up Load Balancer Controller... =========="
	eksctl create podidentityassociation \
    --cluster br-gw-demo \
    --namespace kube-system \
    --service-account-name aws-load-balancer-controller \
    --well-known-policies="awsLoadBalancerController"
	helm repo add eks https://aws.github.io/eks-charts
	helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=br-gw-demo

# Build target: build image and push to ECR
build:
	@echo "\n========== Building and push the image to ECR... =========="
	@cd scripts && ./push-to-ecr.sh

# Run target: deploy manifest to k8s
deploy:
	@echo "\n========== Deploying manifest to k8s... =========="
	kubectl apply -f deployment/k8s/manifest.yaml

ingress:
	@echo "\n========== Deploying ingress... =========="
	kubectl apply -f deployment/k8s/ingress.yaml

# Local development
dev: compose-up

compose-up:
	@echo "\n========== Launching the Bedrock proxy api locally... =========="
	docker-compose up

compose-down:
	@echo "\n========== Destroying the Bedrock proxy api locally... =========="
	docker-compose down

IMAGE_NAME := private-code-generator
IMAGE_TAG := 0.0.7
AWS_ACCOUNT_ID := $(shell echo $(AWS_ACCOUNT_ID))
AWS_REGION ?= eu-west-1

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) ./sagemaker_image

run:
	docker run -it --rm --name $(IMAGE_NAME) -p 8080:8080 $(IMAGE_NAME):$(IMAGE_TAG)

login_ecr:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

push_ecr:
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME):$(IMAGE_TAG)

bootstrap:
	cd account_bootstrap && terraform init && terraform apply -var-file=terraform.tfvars && cd ..

setup-endpoint:
	cd endpoint && terraform init && terraform apply -var-file=terraform.tfvars && cd ..


#!/bin/bash

# 수정
AWS_ID=123456
PROFILE=dev

DOCKER_IMAGE=app-image:1.0
ECR_IMAGE=$AWS_ID.dkr.ecr.ap-northeast-2.amazonaws.com/app-repo:app-image:1.0

################################################################################

docker pull $DOCKER_IMAGE
docker tag $DOCKER_IMAGE $ECR_IMAGE

aws ecr get-login-password \
    --region ap-northeast-2 \
    --profile $PROFILE |
    docker login \
        --username AWS \
        --password-stdin $AWS_ID.dkr.ecr.ap-northeast-2.amazonaws.com

docker push $ECR_IMAGE

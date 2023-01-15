#! /bin/bash


# https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster
kind load docker-image product-domain-service:latest --name micro-service

# image           
# image_pull_policy = "IfNotPresent"

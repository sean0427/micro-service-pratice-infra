# Setup Kind

## Install

[Doc](https://kind.sigs.k8s.io/docs/user/quick-start/)


```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## Create cluster

*kubectl needed*

```bash
kind create cluster --name micro-service
kubectl cluster-info --context kind-micro-service
```

and you will set the kind-cluster in you `.kube/cofig`
# helm-charts


# Usage

1. Minikube

`minikube start --cpus 4 --memory 4g`

2. ArgoCD
- addon-charts/argo-cd

```sh
git clone https://github.com/argoproj/argo-helm.git
cd argo-helm/charts/argo-cd # 해당 폴더를 chart로 생성

# dependency
helm repo add redis-ha https://dandydeveloper.github.io/charts 
helm dependency build

# install
helm install argocd . --kube-context minikube

# password 확인
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d # id: admin, password: %이전까지의 값

minikube service argocd-server
```

3. Istio

```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm search repo istio # repo 확인

# 원하는 경로에 chart.zip pull
helm pull istio/base
helm pull istio/d
helm pull istio/gateway
tar -zxvf base-1.17.2.tgz
tar -zxvf istiod-1.17.2.tgz
tar -zxvf gateway-1.17.2.tgz

# argocd application으로 등록 후 배포 (namespace: istio-system)
1. addon-charts/istio-base
2. addon-charts/istiod
3. addon-charts/istio-ingress
4. addon-charts/gateway
```

4. test-app
- app-charts/test-app

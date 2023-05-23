# helm-charts


# Basic

## 1. Minikube

minikube 시작

`minikube start --cpus 4 --memory 4g`

<br>

## 2. ArgoCD

> namespace: default

charts
- addon-charts/argo-cd

chart 생성 방법
```sh
git clone https://github.com/argoproj/argo-helm.git
cp -r argo-helm/charts/argo-cd . # 해당 폴더를 chart로 생성

# dependency
helm repo add redis-ha https://dandydeveloper.github.io/charts 
helm dependency build
```

설치
```sh
# install
helm install argocd . --kube-context minikube
```

접속
```sh
# password 확인
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d # id: admin, password: %이전까지의 값

minikube service argocd-server
# 출력되는 IP로 접속
```

<br>

## 3. Istio

> namespace: istio-system

charts
- addon-charts/istio-base 
- addon-charts/istiod
- addon-charts/istio-ingress

chart 생성 방법
```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm search repo istio # repo 확인

# 원하는 경로에 chart.zip pull
helm pull istio/base
helm pull istio/d
#helm pull istio/gateway
tar -zxvf base-1.17.2.tgz
tar -zxvf istiod-1.17.2.tgz
#tar -zxvf gateway-1.17.2.tgz
rm *.tgz

# instio-ingress
git clone https://github.com/istio/istio.git
cp -r istio/manifests/charts/gateways/istio-ingress .
```

설치
- ArgoCD 앱에서 설치
- 순서: istio-base -> istiod -> istio-ingress

<br>

## 4. Gateway

> namespace: msa

charts
- addon-charts/gateway

설치
- ArgoCD 앱에서 설치

<br>

## 5. test-app

> namespace: msa

charts
- app-charts/test-app

설치
- ArgoCD 앱에서 설치


<br>
<br>

# Add-on

## Kiali

> namespace: istio-system

charts
- addon-charts/kiali-operator

chart 생성 방법
```sh
helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm pull kiali/kiali-operator
tar -zxvf kiali-operator-1.68.0.tgz
rm *.tgz
```

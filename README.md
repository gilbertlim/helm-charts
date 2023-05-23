# helm-charts


# Basic

## 1. Minikube

minikube 시작

`minikube start --cpus 4 --memory 6g`

LoadBalancer type의 Service 접속 설정
`sudo minikube tunnel --cleanup`

- EXTERNAL-IP를 localhost로 할당하여 로컬에서 port로 구분하여 접속
- 접속할 앱의 service type을 LoadBalancer로 변경하고, Port가 겹치지 않도록 설정

|service|host|port|url|
|---|---|---|---|
|argocd|localhost|8443|https://localhost:8443|
|prometheus|localhost|60001|http://localhost:60001|
|kiali|localhost|20001|http://localhost:20001|
|grafana|localhost|50001|http://localhost:50001|

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
helm install argocd . --namespace argocd --kube-context minikube
```

접속
- id: `admin`
- password: `kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- https://localhost:8443


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
tar -zxvf *.tgz
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

접속
- Chrome extension ModHeader 사용 후 `Host: web.test-app.com` 헤더 적용
- http://127.0.0.1


<br>
<br>

# Add-on

> 쉽게 설치하는 방법: https://github.com/istio/istio/tree/master/samples/addons

## Prometheus

> namespace: monitoring

charts
- addon-charts/prometheus

chart 생성 방법
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm search repo prometheus-community
helm pull prometheus-community/prometheus
tar -zxvf *.tgz
rm *.tgz
```

접속
- http://localhost:60001

<br>

## Kiali

> namespace: istio-system

charts
- addon-charts/kiali-operator

chart 생성 방법
```sh
helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm search repo kiali
helm pull kiali/kiali-operator
helm pull kiali/kiali-server                     
tar -zxvf *.tgz
rm *.tgz
```

접속
- http://localhost:20001

<br>

## Grafana

> namespace: monitoring

charts
- addon-charts/kiali-operator

chart 생성 방법
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm pull grafana/grafana
tar -zxvf *.tgz
rm *.tgz
```

접속
- id : `kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-user}' | base64 -d`
- password : `kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-password}' | base64 -d`
- http://localhost:50001
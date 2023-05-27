# helm-charts

<br>

# Preparation

1. Start minikube
2. Create namespace
3. Install argo-cd
4. Create app-of-apps application in argocd
5. deploy app-of-apps
6. sync all argocd applications

<br>

## 1. Minikube

minikube 시작

`minikube start --cpus 4 --memory 8g`

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

## 2. Namespace

charts
- init-charts/namespace

설치
- `helm install namespace . --kube-context minikube`

이후 argocd에 애플리케이션 등록

<br>

## 3. ArgoCD

> namespace: argocd

charts
- addon-charts/argo-cd

chart 생성 방법
```sh
git clone https://github.com/argoproj/argo-helm.git
cp -r argo-helm/charts/argo-cd . # 해당 폴더를 chart로 생성
rm -rf argo-helm

# dependency
helm repo add redis-ha https://dandydeveloper.github.io/charts 
helm dependency build
```

values.yaml 수정
```yaml
server:
  #...
  service:
    #...    
    # -- Server service type
    type: LoadBalancer # ClusterIP
    # -- Server service http port
    servicePortHttp: 8880 #80
    # -- Server service https port
    servicePortHttps: 8443 #443
```

설치
- `helm install argocd . --namespace argocd --kube-context minikube`

접속
- id: `admin`
- password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- https://localhost:8443

<br>

## 4. App of Apps

ArgoCD 애플리케이션 생성을 위한 app chart
- ArgoCD에서 app-of-apps 애플리케이션을 생성하고 배포하면 templates에 있는 대로 애플리케이션이 생성됨
- 추후 sync를 눌러 각 애플리케이션을 배포


charts
- addon-charts/app-of-apps

values.yaml 수정
```yaml
spec:
  destination:
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/gilbertlim/helm-charts
    targetRevision: main
```

<br>

# App charts
<br>

## test-app

> namespace: msa

charts
- app-charts/test-app

설치
- ArgoCD 앱에서 설치

접속
- Chrome extension ModHeader 사용 후 `Host: istio.test-app.com` 헤더 적용
- http://127.0.0.1

<br>

# Addon charts

<br>

## Istio
쉽게 설치하는 방법: https://github.com/istio/istio/tree/master/samples/addons

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

values.yaml 수정
```yaml
pilot:
  # ...
  # Resources for a small pilot install
  resources:
    requests:
      cpu: 500m
      memory: 512Mi # 2048Mi
```

설치
- ArgoCD 앱에서 설치
- 순서: istio-base -> istiod -> istio-ingress

<br>

## Gateway

> namespace: msa

charts
- addon-charts/gateway

설치
- ArgoCD 앱에서 설치

<br>

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

values.yaml 수정
```yaml
service:
  #...
  servicePort: 60001 #80
  sessionAffinity: None
  type: LoadBalancer #ClusterIP
```

접속
- http://localhost:60001

<br>

## Kiali

> namespace: istio-system

charts
- addon-charts/kiali-operator
- addon-charts/kiali-server

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

values.yaml 수정
```yaml
auth:
  openid: {}
  openshift: {}
  strategy: "anonymous" #""

deployment:
  service_type: "LoadBalancer" #""

external_services:
  custom_dashboards:
    enabled: true
  istio:
    root_namespace: ""
  prometheus:
    custom_metrics_url: http://prometheus-server.monitoring.svc.cluster.local:60001/
    url: http://prometheus-server.monitoring.svc.cluster.local:60001/
    component_status:
      app_label: "prometheus"
      is_core: true
      namespace: "monitoring"

server:
  port: 20001
  metrics_enabled: true
  metrics_port: 9090
  web_root: ""      
```

접속
- http://localhost:20001

<br>

## Grafana

> namespace: monitoring

charts
- addon-charts/grafana

chart 생성 방법
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm pull grafana/grafana
tar -zxvf *.tgz
rm *.tgz
```

values.yaml 수정
```yaml
service:
  enabled: true
  type: LoadBalancer #ClusterIP
  port: 50001 #80
  targetPort: 3000

#...  

# Administrator credentials when not using an existing secret (see below)
adminUser: admin
adminPassword: admin #strongpassword
```

접속
- id : admin (`kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-user}' | base64 -d`)
- password : admin (`kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-password}' | base64 -d`)
- http://localhost:50001

<br>

## Pinpoint

> namespace: monitoring

charts
- addon-charts/pinpoint

chart 생성 방법
```sh
git clone https://github.com/headless-dev/pinpoint-kubernetes.git
cp -r pinpoint-kubernetes/pinpoint . # 해당 폴더를 chart로 생성
rm -rf pinpoint-kubernetes

# helm repo add mysql https://charts.helm.sh/stable                            

# > helm repo add gradiant https://gradiant.github.io/bigdata-charts
# > helm repo add incubator https://charts.helm.sh/incubator
# > helm repo add stable https://charts.helm.sh/stable
# helm dependency update .
```

pinpoint/values.yaml 수정
```yaml
pinpoint-hbase:
  #...
  resources:
    requests:
      memory: "512Mi" # "4Gi"
      cpu: "500m" # "1"
```

pinpoint/charts/pinpoint-hbase/values.yaml 수정
```yaml
resources:
  requests:
    memory: "512Mi" # "4Gi"
    cpu: "500m" # "1"
```

pinpoint/charts/pinpoint-web/templates/service.yaml 수정
```yaml
spec:
  ports:
    - name: ui
      port: {{ .Values.service.port }}
      targetPort: 8080
  type: {{ .Values.service.type }}
```
pinpoint/charts/pinpoint-web/values.yaml 수정
```yaml
service:
  type: LoadBalancer
  port: 40001
```
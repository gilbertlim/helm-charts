# Introduction

로컬에서 이것저것 테스트하기 위한 헬름 차트입니다.

<br><br><br><br><br>

# Quick Start

<br>

## 1. Start minikube

minikube 
```sh
minikube start --cpus 4 --memory 8g
```

<br>

mertrics-server
```sh
sudo minikube addons enable metrics-server
```

<br>

tunneling
- EXTERNAL-IP를 localhost로 할당하여 로컬에서 port로 구분하여 접속
- 접속할 앱의 service type을 LoadBalancer로 지정하면 자동으로 터널링
- Port가 겹치지 않도록 설정 필요
```sh
sudo minikube tunnel --cleanup
```

<br>

## 2. Helm install

```sh
cd helm-charts/helm-charts

# create namespace
helm install namespace init-charts/namespace -f init-charts/namespace/values.yaml --kube-context minikube

# install argo-cd
helm install argocd addon-charts/argo-cd -f addon-charts/argo-cd/values.yaml --namespace argocd --kube-context minikube
```

<br>

## 3. App-of-apps

argocd login
```sh
# id: admin
# password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

<br>

create app-of-apps
```
- GENERAL > Application Name: app-of-apps
- GENERAL > Project Name: default
- SOURCE > Repository URL: https://github.com/gilbertlim/helm-charts.git
- SOURCE > Revision: main
- SOURCE > Path: helm-charts/addon-charts/app-of-apps
- DESTINATION > Cluster URL: https://kubernetes.default.svc
- DESTINATION > Namespace: argocd
- Helm > VALUES FILES: values.yaml
```

<br>

sync app-of-apps !

<br>

### App dependency
- istio-ingress, gateway > istiod > istio-base
- grafana, kiali > prometheus
- pinpoint-web, pinpoint-collector > pinpoint-hbase
- *-test-app > argo-rollouts, pinpoint

<br>
<br>
<br>

# Access

|service|host|port|url|
|---|---|---|---|
|argocd|localhost|8443|https://localhost:8443|
|kiali|localhost|20001|http://localhost:20001|
|pinpoint|localhost|40001|http://localhost:40001|
|grafana|localhost|50001|http://localhost:50001|
|prometheus|localhost|60001|http://localhost:60001|

<br><br><br><br><br>

=======================================================================================================

<br>

Descriptions

<br>

# Namespace

charts
- init-charts/namespace

<br>

설치
- `helm install namespace . --kube-context minikube`

<br>

이후 argocd에 애플리케이션 등록

<br><br><br><br><br>

# ArgoCD

> namespace: argocd

<br>

charts
- addon-charts/argo-cd

<br>

chart 생성 방법
```sh
git clone https://github.com/argoproj/argo-helm.git
cp -r argo-helm/charts/argo-cd . # 해당 폴더를 chart로 생성
rm -rf argo-helm

# dependency
helm repo add redis-ha https://dandydeveloper.github.io/charts 
helm dependency build
```

<br>

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

<br>

설치
- `helm install argocd . --namespace argocd --kube-context minikube`

<br>

접속
- id: `admin`
- password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- https://localhost:8443

<br><br><br><br><br>

# App of Apps

> namespace: argocd

<br>

ArgoCD 애플리케이션 생성을 위한 app chart
- ArgoCD에서 app-of-apps 애플리케이션을 생성하고 배포하면 templates에 있는 대로 애플리케이션이 생성됨
- 추후 sync를 눌러 각 애플리케이션을 배포

<br>

charts
- addon-charts/app-of-apps

<br>

values.yaml 수정
```yaml
spec:
  destination:
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/gilbertlim/helm-charts
    targetRevision: main
```

<br><br><br><br><br>

# App charts

<br>

## istio-test-app

> namespace: msa

<br>

charts
- app-charts/test-app

<br>

설치
- ArgoCD 앱에서 설치

<br>

접속
- Chrome extension ModHeader 사용 후 `Host: istio.test-app.com` 헤더 적용
- http://127.0.0.1

<br>

## mysql (local)

minikube cluster 내부 pod에서 로컬의 mysql container에 접근하는 방식 적용

<br>

mysql container
```sh
docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql
```

<br>

sql
1. `docker exec -it mysql /bin/bash`
2. `mysql -u root -p`
3. `create database member_service;` 
4. run sql
  ```sql
  DROP DATABASE IF EXISTS member_service;
  CREATE DATABASE member_service;
  USE member_service;
  DROP TABLE IF EXISTS tbl_member CASCADE;
  CREATE TABLE tbl_member (
      member_num INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
      member_id VARCHAR(100) NOT NULL UNIQUE,
      member_name VARCHAR(20)
  );
  
  DROP DATABASE IF EXISTS order_service;
  CREATE DATABASE order_service;
  USE order_service;
  
  DROP TABLE IF EXISTS tbl_order CASCADE;
  CREATE TABLE tbl_order (
      order_num BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
      member_num INT UNSIGNED
  );
  
  DROP TABLE IF EXISTS tbl_order_item CASCADE;
  CREATE TABLE tbl_order_item (
      order_item_num BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
      order_num BIGINT UNSIGNED,
      item_num BIGINT UNSIGNED,
      item_count SMALLINT UNSIGNED
  );
  ```

<br>

## member

<br>

- repository: `https://github.com/gilbertlim/member-service.git`

<br>

Dockerfile
```dockerfile
FROM --platform=$BUILDPLATFORM openjdk:17.0.1
COPY build/libs/member-service-*-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-jar", "./app.jar"]
```

<br>

push image (multiplatform)
```sh
./gradlew build -x test

docker run --privileged --rm tonistiigi/binfmt --install all
docker context ls # check context
# docker buildx create --name multiarch-builder <context> --use
docker buildx create --name multiarch-builder default --use

docker buildx build --platform linux/amd64,linux/arm64 -t 9ilbert/member:0.0 . --push
```

<br>

container test
```sh
docker run -d --name member -e DB_CONNECTION_URL=jdbc:mysql://$(docker inspect mysql | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'):3306/member_service -e DB_USER=root -e DB_PASSWORD=password member:0.0
```

<br>

### Secrets

db에 접근할 msa app 배포 시 db 접속 정보를 secret으로 등록해주어야 함.

<br>

db 접속 정보 등록
```sh
# local의 en0 interface 확인
ifconfig en0 | egrep -o 'inet ([0-9\.]*)' | awk '{print $2}'
```

<br>

app-charts/member/secret/mysql.yaml (필요 시 .gitignore 등록)
```yaml
#url: jdbc:mysql://<en0 interface ip>:<db port>/<db name>
url: jdbc:mysql://172.16.23.223/member_service
username: root
password: password
```

<br><br><br><br><br>

# Addon charts

<br>

## Istio

> namespace: istio-system

<br>

쉽게 설치하는 방법: https://github.com/istio/istio/tree/master/samples/addons

<br>

charts
- addon-charts/istio-base 
- addon-charts/istiod
- addon-charts/istio-ingress

<br>

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

<br>

설치
- ArgoCD 앱에서 설치
- 순서: istio-base -> istiod -> istio-ingress

<br><br><br>

## Gateway

> namespace: msa

<br>

charts
- addon-charts/gateway

<br>

설치
- ArgoCD 앱에서 설치

<br><br><br>

## Prometheus

> namespace: monitoring

<br>

charts
- addon-charts/prometheus

<br>

chart 생성 방법
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm search repo prometheus-community
helm pull prometheus-community/prometheus
tar -zxvf *.tgz
rm *.tgz
```

<br>

values.yaml 수정
```yaml
service:
  #...
  servicePort: 60001 #80
  sessionAffinity: None
  type: LoadBalancer #ClusterIP
```

<br>

접속
- http://localhost:60001

<br><br><br>

## Kiali

> namespace: istio-system

<br>

charts
- addon-charts/kiali-operator
- addon-charts/kiali-server

<br>

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

<br>

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

<br>

접속
- http://localhost:20001

<br><br><br>

## Grafana

> namespace: monitoring

<br>

charts
- addon-charts/grafana

<br>

chart 생성 방법
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm pull grafana/grafana
tar -zxvf *.tgz
rm *.tgz
```

<br>

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

<br>

접속
- id : admin (`kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-user}' | base64 -d`)
- password : admin (`kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-password}' | base64 -d`)
- http://localhost:50001

<br><br><br>

## Pinpoint

> namespace: monitoring

<br>

charts
- addon-charts/pinpoint

<br>

chart 생성 방법
```sh
git clone https://github.com/gilbertlim/pinpoint-helm-charts.git
cp -r pinpoint-helm-charts/pinpoint . # 해당 폴더를 chart로 생성
rm -rf pinpoint-helm-charts
```

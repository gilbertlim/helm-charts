{{/*
Expand the name of the chart.
*/}}
{{- define "product-grpc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "product-grpc.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "product-grpc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "product-grpc.labels" -}}
{{ include "product-grpc.selectorLabels" . }}
version: stable
{{- end }}

{{/*
Service labels
*/}}
{{- define "product-grpc.serviceLabels" -}}
service: {{ include "product-grpc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "product-grpc.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "product-grpc.selectorLabels" -}}
app: {{ include "product-grpc.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "product-grpc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "product-grpc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

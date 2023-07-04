{{/*
Expand the name of the chart.
*/}}
{{- define "order-grpc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "order-grpc.fullname" -}}
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
{{- define "order-grpc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "order-grpc.labels" -}}
{{ include "order-grpc.selectorLabels" . }}
version: stable
{{- end }}

{{/*
Service labels
*/}}
{{- define "order-grpc.serviceLabels" -}}
service: {{ include "order-grpc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "order-grpc.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "order-grpc.selectorLabels" -}}
app: {{ include "order-grpc.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "order-grpc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "order-grpc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

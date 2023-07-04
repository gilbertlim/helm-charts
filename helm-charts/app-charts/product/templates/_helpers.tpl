{{/*
Expand the name of the chart.
*/}}
{{- define "product.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "product.fullname" -}}
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
{{- define "product.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "product.labels" -}}
{{ include "product.selectorLabels" . }}
version: stable
{{- end }}

{{/*
Service labels
*/}}
{{- define "product.serviceLabels" -}}
service: {{ include "product.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "product.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "product.selectorLabels" -}}
app: {{ include "product.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "product.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "product.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

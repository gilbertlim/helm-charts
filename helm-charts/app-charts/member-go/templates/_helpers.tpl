{{/*
Expand the name of the chart.
*/}}
{{- define "member.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "member.fullname" -}}
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
{{- define "member.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "member.labels" -}}
{{ include "member.selectorLabels" . }}
version: stable
{{- end }}

{{/*
Service labels
*/}}
{{- define "member.serviceLabels" -}}
service: {{ include "member.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "member.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "member.selectorLabels" -}}
app: {{ include "member.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "member.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "member.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cd.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cd.labels" -}}
helm.sh/chart: {{ include "cd.chart" . }}
{{ include "cd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "cd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "cd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "cd.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
{{/*
  Define the name of the sql secret
*/}}
{{- define "cd.secretName" -}}
{{ printf "%s-%s" (include "cd.fullname" .) "secret" | trunc 63 | trimSuffix "-"  }}
{{- end -}}
{{/*
Create a default fully qualified solr name.
*/}}
{{- define "solr.fullName" -}}
{{- if .Values.solrServiceNameOverride -}}
{{- .Values.solrServiceNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "solr" .Values.solrServiceNameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified sql name.
*/}}
{{- define "sql.fullName" -}}
{{- if .Values.sqlServiceNameOverride -}}
{{- .Values.sqlServiceNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "sql" .Values.sqlServiceNameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified xconnect name.
*/}}
{{- define "xconnect.fullName" -}}
{{- if .Values.xconnectServiceNameOverride -}}
{{- .Values.xconnectServiceNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "xconnect" .Values.xconnectServiceNameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
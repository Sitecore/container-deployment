{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sql.fullname" -}}
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
{{- define "sql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sql.labels" -}}
helm.sh/chart: {{ include "sql.chart" . }}
{{ include "sql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "sql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "sql.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
  Define the name of the sql PVC
*/}}
{{- define "sql.pvcName" -}}
{{ printf "%s-%s" (include "sql.fullname" .) "pvc" | trunc 63 | trimSuffix "-"  }}
{{- end -}}

{{/*
  Define the name of the sql secret
*/}}
{{- define "sql.secretName" -}}
{{ printf "%s-%s" (include "sql.fullname" .) "secret" | trunc 63 | trimSuffix "-"  }}
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

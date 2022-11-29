{{/*
Expand the name of the chart.
*/}}
{{- define "aloha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aloha.fullname" -}}
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
{{- define "aloha.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aloha.labels" -}}
helm.sh/chart: {{ include "aloha.chart" . }}
{{ include "aloha.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aloha.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aloha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "aloha.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "aloha.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
include all env variables for aloha pods
*/}}
{{- define "aloha.env" -}}
- name: DB_HOST
  value: "{{ template "postgresql.primary.fullname" .Subcharts.postgresql }}"
- name: DB_HOST_PORT
  value: "{{ template "postgresql.service.port" .Subcharts.postgresql }}"
- name: DB_USER
  value: "postgres"
- name: SETTING_MEMCACHED_LOCATION
  value: "{{ template "common.names.fullname" .Subcharts.memcached }}:11211"
- name: SETTING_RABBITMQ_HOST
  value: "{{ template "rabbitmq.fullname" .Subcharts.rabbitmq }}"
- name: SETTING_REDIS_HOST
  value: "{{ template "common.names.fullname" .Subcharts.redis }}-headless"
- name: SECRETS_rabbitmq_password
  value: "{{ .Values.rabbitmq.auth.password }}"
- name: SECRETS_postgres_password
  value: "{{ .Values.postgresql.auth.password }}"
- name: SECRETS_memcached_password
  value: "{{ .Values.memcached.memcachedPassword }}"
- name: SECRETS_redis_password
  value: "{{ .Values.redis.auth.password }}"
- name: SECRETS_secret_key
  value: "{{ .Values.aloha.password }}"
{{- range $key, $value := .Values.aloha.environment }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Chart name, overridable.
*/}}
{{- define "stelaris-ui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name. Truncated at 63 characters, because some Kubernetes
name fields are limited to that.
*/}}
{{- define "stelaris-ui.fullname" -}}
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

{{- define "stelaris-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "stelaris-ui.labels" -}}
helm.sh/chart: {{ include "stelaris-ui.chart" . }}
{{ include "stelaris-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: stelaris
{{- end }}

{{- define "stelaris-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stelaris-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "stelaris-ui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "stelaris-ui.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The image reference. An empty tag means the chart's appVersion, so a release of
the chart always describes the image built from the same commit.
*/}}
{{- define "stelaris-ui.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- if .Values.image.registry -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository $tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end }}

{{/*
The Secret holding config.json - the one this chart creates, or an existing one.
*/}}
{{- define "stelaris-ui.configSecretName" -}}
{{- default (printf "%s-config" (include "stelaris-ui.fullname" .)) .Values.config.existingSecret }}
{{- end }}

{{/*
Whether anything overrides the nginx configuration in the image. Used to decide
whether the ConfigMap and its mounts exist at all.
*/}}
{{- define "stelaris-ui.hasNginxOverrides" -}}
{{- if or .Values.nginx.contentSecurityPolicy .Values.nginx.serverConfig -}}
true
{{- end -}}
{{- end }}

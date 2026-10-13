{{/* Labels communs ajoutés à toutes les ressources (en plus du label "app" utilisé par les selectors) */}}
{{- define "kube-starter.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

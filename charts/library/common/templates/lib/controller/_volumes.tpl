{{/*
Volumes included by the controller.
*/}}
{{- define "geek-cookbook.common.controller.volumes" -}}
{{- range $index, $persistence := .Values.persistence }}
{{- $globalVar := get $.Values.global (printf "%s" $index) }}
{{ $globalOverride := "" }}
{{- if not $globalVar }}
{{ $globalOverride = $persistence.enabled }}
{{- else }}
{{ $globalOverride = $globalVar.enabled }}
{{- end }}
{{- if $globalOverride }}
- name: {{ $index }}
  {{- if eq (default "pvc" $persistence.type) "pvc" }}
    {{- $pvcName := (include "geek-cookbook.common.names.fullname" $) -}}
    {{- if $persistence.existingClaim }}
      {{- /* Always prefer an existingClaim if that is set */}}
      {{- $pvcName = $persistence.existingClaim -}}
    {{- else -}}
      {{- /* Otherwise refer to the PVC name */}}
      {{- if $persistence.nameOverride -}}
        {{- if not (eq $persistence.nameOverride "-") -}}
          {{- $pvcName = (printf "%s-%s" (include "geek-cookbook.common.names.fullname" $) $persistence.nameOverride) -}}
        {{- end -}}
      {{- else -}}
        {{- $pvcName = (printf "%s-%s" (include "geek-cookbook.common.names.fullname" $) $index) -}}
      {{- end -}}
    {{- end }}
  persistentVolumeClaim:
    claimName: {{ $pvcName }}
  {{- else if or (eq $persistence.type "configMap") (eq $persistence.type "secret") }}
    {{- $objectName := (required (printf "name not set for persistence item %s" $index) $persistence.name) }}
    {{- $objectName = tpl $objectName $ }}
    {{- if eq $persistence.type "configMap" }}
  configMap:
    name: {{ $objectName }}
    {{- else }}
  secret:
    secretName: {{ $objectName }}
    {{- end }}
    {{- with $persistence.defaultMode }}
    defaultMode: {{ . }}
    {{- end }}
    {{- with $persistence.items }}
    items:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else if eq $persistence.type "emptyDir" }}
    {{- $emptyDir := dict -}}
    {{- with $persistence.medium -}}
      {{- $_ := set $emptyDir "medium" . -}}
    {{- end -}}
    {{- with $persistence.sizeLimit -}}
      {{- $_ := set $emptyDir "sizeLimit" . -}}
    {{- end }}
  emptyDir: {{- $emptyDir | toYaml | nindent 4 }}
  {{- else if eq $persistence.type "hostPath" }}
  hostPath:
    path: {{ required "hostPath not set" $persistence.hostPath }}
    {{- with $persistence.hostPathType }}
    type: {{ . }}
    {{- end }}
  {{- else if eq $persistence.type "nfs" }}
  nfs:
    server: {{ required "server not set" $persistence.server }}
    path: {{ required "path not set" $persistence.path }}
  {{- else if eq $persistence.type "custom" }}
    {{- toYaml $persistence.volumeSpec | nindent 2 }}
  {{- else }}
    {{- fail (printf "Not a valid persistence.type (%s)" .Values.persistence.type) }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

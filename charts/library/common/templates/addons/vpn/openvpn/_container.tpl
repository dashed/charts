{{/*
The OpenVPN sidecar container to be inserted.
*/}}
{{- define "geek-cookbook.common.addon.openvpn.container" -}}
name: openvpn
image: "{{ .Values.addons.vpn.openvpn.image.repository }}:{{ .Values.addons.vpn.openvpn.image.tag }}"
imagePullPolicy: {{ .Values.addons.vpn.openvpn.pullPolicy }}
{{- with .Values.addons.vpn.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.addons.vpn.env }}
env:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with .Values.addons.vpn.envFrom }}
envFrom:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with .Values.addons.vpn.args }}
args:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- if or .Values.addons.vpn.openvpn.auth .Values.addons.vpn.openvpn.authSecret }}
envFrom:
  - secretRef:
    {{- if .Values.addons.vpn.openvpn.authSecret }}
      name: {{ .Values.addons.vpn.openvpn.authSecret }}
    {{- else }}
      name: {{ include "geek-cookbook.common.names.fullname" . }}-openvpn
    {{- end }}
{{- end }}
{{- if or .Values.addons.vpn.configFile .Values.addons.vpn.configFileSecret .Values.addons.vpn.scripts.up .Values.addons.vpn.scripts.down .Values.addons.vpn.additionalVolumeMounts .Values.persistence.shared.enabled }}
volumeMounts:
{{- if or .Values.addons.vpn.configFile .Values.addons.vpn.configFileSecret }}
  - name: vpnconfig
    mountPath: /vpn/vpn.conf
    subPath: vpnConfigfile
{{- end }}
{{- if .Values.addons.vpn.scripts.up }}
  - name: vpnscript
    mountPath: /vpn/up.sh
    subPath: up.sh
{{- end }}
{{- if .Values.addons.vpn.scripts.down }}
  - name: vpnscript
    mountPath: /vpn/down.sh
    subPath: down.sh
{{- end }}
{{- if .Values.persistence.shared.enabled }}
  - mountPath: {{ .Values.persistence.shared.mountPath }}
    name: shared
{{- end }}
{{- with .Values.addons.vpn.additionalVolumeMounts }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- with .Values.addons.vpn.livenessProbe }}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end -}}
{{- with .Values.addons.vpn.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

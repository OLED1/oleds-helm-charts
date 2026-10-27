{{/*
Expand the name of the chart.
*/}}
{{- define "cmsms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cmsms.fullname" -}}
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
{{- define "cmsms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cmsms.labels" -}}
helm.sh/chart: {{ include "cmsms.chart" . }}
{{ include "cmsms.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cmsms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cmsms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cmsms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cmsms.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Normalize an existingSecret value (string = new format, map = legacy 0.1.x format)
Returns YAML: { name: <secret name or "">, legacy: <bool>, <key>: <key name>, ... }
Usage: include "cmsms.existingSecret" (dict "root" $ "value" <val> "path" "<values path>" "defaults" (dict "usernameKey" "..." ...)) | fromYaml
*/}}
{{- define "cmsms.existingSecret" -}}
{{- $v := .value -}}
{{- $d := .defaults -}}
{{- $out := dict "name" "" "legacy" false -}}
{{- range $k, $def := $d -}}
  {{- $_ := set $out $k $def -}}
{{- end -}}
{{- if kindIs "map" $v -}}
  {{- $_ := set $out "legacy" true -}}
  {{- if $v.enabled -}}
    {{- $name := required (printf "%s.existingSecret.secretName is required when %s.existingSecret.enabled=true" .path .path) $v.secretName -}}
    {{- $_ := set $out "name" (tpl (toString $name) .root) -}}
    {{- range $k, $def := $d -}}
      {{- $_ := set $out $k (get $v $k | default $def) -}}
    {{- end -}}
  {{- end -}}
{{- else if $v -}}
  {{- $_ := set $out "name" (tpl (toString $v) .root) -}}
{{- end -}}
{{- toYaml $out -}}
{{- end -}}

{{/*
Name of the secret used by the bundled Bitnami MariaDB
(mariadb.auth.existingSecret, or the generated <release>-mariadb)
*/}}
{{- define "cmsms.mariadb.secretName" -}}
{{- if and .Values.mariadb.enabled (not .Values.externalDatabase.enabled) -}}
  {{- include "mariadb.secretName" .Subcharts.mariadb -}}
{{- end -}}
{{- end -}}

{{/*
Active DB existingSecret (external or internal), normalized.
Returns YAML: { name, legacy, usernameKey, passwordKey, bitnami, username }

Bitnami fallback (internal MariaDB only): CMSMS reads its password from the
MariaDB secret (key mariadb-password) and its username as a plain value
(db_authentication.username, else mariadb.auth.username). Active when either
  a) mariadb.auth.existingSecret is set and neither db_authentication.password
     nor db_authentication.existingSecret is given, or
  b) db_authentication.existingSecret points to the MariaDB secret itself,
     which has no db-username / db-password keys.
In that case usernameKey is "" and username holds the plain value.
Keys set explicitly in the legacy object format still win.
*/}}
{{- define "cmsms.db.existingSecret" -}}
{{- $defaults := dict "usernameKey" "db-username" "passwordKey" "db-password" -}}
{{- if .Values.externalDatabase.enabled -}}
  {{- $es := include "cmsms.existingSecret" (dict "root" . "value" .Values.externalDatabase.existingSecret "path" "externalDatabase" "defaults" $defaults) | fromYaml -}}
  {{- $_ := set $es "bitnami" false -}}
  {{- $_ := set $es "username" "" -}}
  {{- toYaml $es -}}
{{- else -}}
  {{- $auth := .Values.cmsms_settings.db_authentication -}}
  {{- $raw := $auth.existingSecret -}}
  {{- $es := include "cmsms.existingSecret" (dict "root" . "value" $raw "path" "cmsms_settings.db_authentication" "defaults" $defaults) | fromYaml -}}
  {{- $_ := set $es "bitnami" false -}}
  {{- $_ := set $es "username" "" -}}
  {{- $mdbSecret := include "cmsms.mariadb.secretName" . -}}
  {{- if $mdbSecret -}}
    {{- $useMdb := false -}}
    {{- if and (not $es.name) .Values.mariadb.auth.existingSecret (not $auth.password) -}}
      {{- $useMdb = true -}}
      {{- $_ := set $es "name" $mdbSecret -}}
    {{- else if eq $es.name $mdbSecret -}}
      {{- $useMdb = true -}}
    {{- end -}}
    {{- if $useMdb -}}
      {{- $explicit := dict -}}
      {{- if and (kindIs "map" $raw) $raw.enabled -}}{{- $explicit = $raw -}}{{- end -}}
      {{- $_ := set $es "bitnami" true -}}
      {{- $_ := set $es "passwordKey" ($explicit.passwordKey | default "mariadb-password") -}}
      {{- $_ := set $es "usernameKey" ($explicit.usernameKey | default "") -}}
      {{- if not $es.usernameKey -}}
        {{- $user := $auth.username | default .Values.mariadb.auth.username -}}
        {{- $_ := set $es "username" (required "cmsms_settings.db_authentication.username or mariadb.auth.username is required when CMSMS uses the MariaDB secret" $user) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $es -}}
{{- end -}}
{{- end -}}

{{/*
Initial user / SMTP existingSecret, normalized
*/}}
{{- define "cmsms.initialUser.existingSecret" -}}
{{- include "cmsms.existingSecret" (dict "root" . "value" .Values.cmsms_settings.initial_user.existingSecret "path" "cmsms_settings.initial_user" "defaults" (dict "usernameKey" "cmsms_username" "passwordKey" "cmsms_password" "emailKey" "cmsms_email")) -}}
{{- end -}}

{{- define "cmsms.smtp.existingSecret" -}}
{{- include "cmsms.existingSecret" (dict "root" . "value" .Values.cmsms_settings.setup_smtp.smtp_auth.existingSecret "path" "cmsms_settings.setup_smtp.smtp_auth" "defaults" (dict "usernameKey" "cmsms_smtp_username" "passwordKey" "cmsms_smtp_password")) -}}
{{- end -}}

{{/*
Returns "true" if the chart must render its own DB secret (<release>-db)
*/}}
{{- define "cmsms.db.createSecret" -}}
{{- $es := include "cmsms.db.existingSecret" . | fromYaml -}}
{{- if and (or .Values.externalDatabase.enabled .Values.mariadb.enabled) (not $es.name) -}}true{{- end -}}
{{- end -}}

{{/*
Secret names: existing secret or chart-generated
*/}}
{{- define "cmsms.db.secretName" -}}
{{- (include "cmsms.db.existingSecret" . | fromYaml).name | default (printf "%s-db" .Release.Name) -}}
{{- end -}}

{{- define "cmsms.initialUser.secretName" -}}
{{- (include "cmsms.initialUser.existingSecret" . | fromYaml).name | default (printf "%s-secrets" .Release.Name) -}}
{{- end -}}

{{- define "cmsms.smtp.secretName" -}}
{{- (include "cmsms.smtp.existingSecret" . | fromYaml).name | default (printf "%s-secrets" .Release.Name) -}}
{{- end -}}
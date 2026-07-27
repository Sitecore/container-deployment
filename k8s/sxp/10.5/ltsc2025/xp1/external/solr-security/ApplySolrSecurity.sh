#!/bin/bash
set -euo pipefail
export LC_ALL=C.UTF-8
: "${SOLR_ADMIN_USERNAME:?}"
: "${SOLR_ADMIN_PASSWORD:?}"

log() { printf '%s %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S.%3N')" "$*"; }

SPEC="/opt/solr-config/security.json"
OUT="/tmp/solr-security-merged.json"
ZK_HOST="${SOLR_ZK_HOST:-localhost:9983}"
ZK_ADDR="${ZK_HOST%:*}"
ZK_PORT="${ZK_HOST##*:}"

log "Waiting for embedded ZooKeeper (${ZK_HOST})..."
while ! echo ruok | timeout 5 nc -w 1 "${ZK_ADDR}" "${ZK_PORT}" 2>/dev/null | grep -q '^imok$'; do
  log "ZooKeeper not ready yet, sleeping 1s..."
  sleep 1
done
log "ZooKeeper is ready."

# Match org.apache.solr.security.Sha256AuthenticationProvider.getSaltedHashedValue / sha256(password, saltBase64)
salt_raw=$(openssl rand 32)
salt_b64=$(printf '%s' "$salt_raw" | base64 -w0)
umask 077
COMB=$(mktemp)
FIRST=$(mktemp)
SECOND=$(mktemp)
trap 'rm -f "$COMB" "$FIRST" "$SECOND"' EXIT
printf '%s' "$salt_raw" > "$COMB"
printf '%s' "$SOLR_ADMIN_PASSWORD" >> "$COMB"
openssl dgst -sha256 -binary -out "$FIRST" "$COMB"
openssl dgst -sha256 -binary -out "$SECOND" "$FIRST"
hash_b64=$(base64 -w0 < "$SECOND")
credential="${hash_b64} ${salt_b64}"

# Read role name and authorization class from the spec file
ADMIN_USER_ROLE_NAME=$(sed -n 's/.*"solrUserRole"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$SPEC" | head -1)
ADMIN_USER_ROLE_NAME="${ADMIN_USER_ROLE_NAME:-sitecoreSolrAdminUserRole}"
GENERAL_USER_ROLE_NAME="sitecoreGeneralUserRole"
AUTH_CLASS=$(sed -n 's/.*"class"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$SPEC" | head -1)
AUTH_CLASS="${AUTH_CLASS:-solr.RuleBasedAuthorizationPlugin}"

# Build the full security.json - the "permissions" array is read directly from the spec file via awk
{
  printf '{"authentication":{"class":"solr.BasicAuthPlugin","blockUnknown":true,"credentials":{"%s":"%s"}},' \
    "${SOLR_ADMIN_USERNAME}" "${credential}"
  printf '"authorization":{"class":"%s","user-role":{"%s":["%s", "%s"]},"permissions":' \
    "${AUTH_CLASS}" "${SOLR_ADMIN_USERNAME}" "${ADMIN_USER_ROLE_NAME}" "${GENERAL_USER_ROLE_NAME}"
  awk '
    /"permissions"[[:space:]]*:/ { found=1; sub(/.*"permissions"[[:space:]]*:[[:space:]]*/, "") }
    found { print }
    found && /^[[:space:]]*\][[:space:]]*$/ { exit }
  ' "$SPEC"
  printf '}}'
} > "$OUT"

log "Uploading merged security.json to ZooKeeper (zk:security.json at ${ZK_HOST})..."
/opt/solr/bin/solr zk cp "$OUT" zk:security.json -z "${ZK_HOST}"
sleep 3
log "Solr security.json applied in ZooKeeper."
#!/usr/bin/env bash
# Run only within coord.py deploy. The tarball contains a tested, pushed commit and its build.
set -euo pipefail
bundle=$1
release=$2
backup=$3
conf=/etc/nginx/conf.d/domains/office.ebaoguo.com.conf
unit=/etc/systemd/system/ebaoguo-office.service
base=/opt/ebaoguo-office
mkdir -p "$backup"
curl -fsS -o /dev/null -w 'Main website baseline: %{http_code}\n' https://ebaoguo.com/ > "$backup/baseline.txt"
nginx -t
# This first installation must not replace an existing site/service without reading it first.
[[ ! -e "$conf" && ! -e "$unit" && ! -e "$base/current" ]]
rollback() {
  systemctl disable --now ebaoguo-office.service || true
  rm -f "$conf" "$unit" "$base/current"
  systemctl daemon-reload
  nginx -t && systemctl reload nginx
}
trap rollback ERR
getent passwd agentoffice >/dev/null || useradd --system --home-dir /var/lib/ebaoguo-office --create-home --shell /bin/bash agentoffice
install -d -m 700 -o agentoffice -g agentoffice /var/lib/ebaoguo-office/.agent-office /var/lib/ebaoguo-office/projects
mkdir -p "$base/releases/$release" /var/lib/ebaoguo-office-acme
# Source + production deps, never root-owned workers or business credentials.
tar xzf "$bundle" -C "$base/releases/$release"
cd "$base/releases/$release"
npm ci --omit=dev --ignore-scripts --no-fund --no-audit > "$backup/npm-ci.log" 2>&1
# Start with individual accounts only, even before the owner redeems the invite.
if [[ ! -e /var/lib/ebaoguo-office/.agent-office/accounts.json ]]; then
  printf '%s\n' '{"accounts":[],"invites":[],"sharedPassword":false}' > /var/lib/ebaoguo-office/.agent-office/accounts.json
  chown agentoffice:agentoffice /var/lib/ebaoguo-office/.agent-office/accounts.json
  runuser -u agentoffice -- node bin/agent-office.js accounts invite Hao --admin --dir /var/lib/ebaoguo-office > "$backup/owner-invite.txt"
  chmod 600 "$backup/owner-invite.txt"
else
  python3 -c 'import json; assert json.load(open("/var/lib/ebaoguo-office/.agent-office/accounts.json"))["sharedPassword"] is False'
fi
ln -s "$base/releases/$release" "$base/current"
cp deploy/office-ebaoguo/office.service "$unit"
# HTTP is challenge-only while the certificate is issued.
head -n 7 deploy/office-ebaoguo/nginx.conf > "$conf"
nginx -t
systemctl reload nginx
certbot certonly --webroot -w /var/lib/ebaoguo-office-acme -d office.ebaoguo.com --non-interactive --agree-tos --register-unsafely-without-email > "$backup/certbot.log" 2>&1
cp deploy/office-ebaoguo/nginx.conf "$conf"
nginx -t
systemctl daemon-reload
systemctl enable --now ebaoguo-office.service
systemctl reload nginx
# Readiness bounded to ten seconds.
for attempt in $(seq 1 20); do
  if curl -fsS http://127.0.0.1:4700/login > "$backup/login.html"; then break; fi
  sleep 0.5
done
grep -q '易包裹' "$backup/login.html"
# Nginx reload returns before new workers finish accepting TLS connections.
for attempt in $(seq 1 20); do
  if curl -fsS --max-time 5 https://office.ebaoguo.com/login > /dev/null 2>&1; then break; fi
  sleep 0.5
done
curl -fsS --max-time 10 https://office.ebaoguo.com/login > /dev/null
curl -fsS https://ebaoguo.com/ > /dev/null
journalctl -u ebaoguo-office.service -n 30 --no-pager > "$backup/service-log.txt"
trap - ERR

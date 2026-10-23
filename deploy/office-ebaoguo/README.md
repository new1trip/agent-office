# office.ebaoguo.com

Dedicated unprivileged systemd service, localhost:4700, Nginx and Let's Encrypt.
New site config is independently managed; Hestia domain rebuilds must preserve it.
Install with `install.sh <staged-tarball> <pushed-commit> <backup-dir>` inside `coord.py deploy` only.
Archive must include bin, dist, package.json, package-lock.json and this directory.
Owner invitation is in backup/owner-invite.txt (root-only, single use, seven days).
Named accounts are required from first boot. Owner chooses a new password on /join,
then invites designated members in the Accounts UI. No shared office password login.

No business repositories or agent credentials are copied. The owner must connect intended
repositories and each operator's provider account before real development. All logged-in
members can operate this dedicated office OS account; project paths are not OS sandboxes.
Maximum one worker per floor; 4 GiB service memory cap. Upstream MIT attribution retained.

Rollback: stop/disable ebaoguo-office, remove only this new site's Nginx config and current
symlink, daemon-reload, nginx -t then reload. Keep /var/lib/ebaoguo-office and release dirs
for recovery; never delete accounts/projects as part of rollback. The install ERR trap
restores the absent pre-install config/service state. No business DB migrations.

Brand: official logo https://ebaoguo.com/wp-content/uploads/2026/07/ebg-main-logo.png.
Music: existing upstream jukebox, manual play, per-browser mute/volume (muted on first visit).
MELODY official player https://audio1.syok.my/amp-melody advertises classic Chinese music;
its live programme includes other eras. Dedicated 80s/90s stream IDs checked on 2026-10-23
returned 404, so they are not offered as working channels. Audio comes directly from the
broadcaster; no music files are stored. Radio availability/regions/programme may vary.

Dependency audit: upstream critical/high issues remediated with lockfile fixes and narrow
overrides (nanoid, Sass, lodash-es); re-run npm audit --audit-level=high before release.

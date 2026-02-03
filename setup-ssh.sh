#!/usr/bin/env bash
set -e

# 1) Gruppe für SSH-Zugriff
groupadd -f ssh-users

# 2) Optional: Admin-User hinzufügen (Name als Argument)
ADMIN_USER="${1:-adminuser}"
if id "$ADMIN_USER" >/dev/null 2>&1; then
  usermod -aG sudo adminuser
  usermod -aG ssh-users "$ADMIN_USER"
else
  echo "User $ADMIN_USER existiert nicht bitte erstellen!, überspringe..."
fi

# 3) SSH-Hardening als Config-Snippet
cat << 'EOF' >/etc/ssh/sshd_config.d/99-hardening.conf
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes

AllowGroups ssh-users
AuthorizedKeysFile .ssh/authorized_keys
EOF

# 4) Config testen und sshd neu starten
sshd -t
systemctl restart sshd
echo "SSH-Hardening fertig. Erlaubte Gruppe: ssh-users"

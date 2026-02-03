#!/usr/bin/env bash
set -e

# 1) Gruppe für SSH-Zugriff
groupadd -f ssh-users

# 2) Optional: Admin-User hinzufügen (Name als Argument)
ADMIN_USER="${1:-adminuser}"
if id "$ADMIN_USER" >/dev/null 2>&1; then
  usermod -aG sudo "$ADMIN_USER"
  usermod -aG ssh-users "$ADMIN_USER"
else
  echo "User $ADMIN_USER existiert nicht bitte erstellen und Skript neu ausführen!, überspringe..."
  exit 1
fi

SSH_DIR="/home/$ADMIN_USER/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
chown "$ADMIN_USER:$ADMIN_USER" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 3) Interaktiv nach Public key fragen
echo "Bitte jetzt den PUBLIC KEY eingeben (eine Zeile) und dann ENTER:"
read -r PUBKEY

if [ -z "$PUBKEY" ]; then
  echo "Kein Key eingegeben, lege leere authorized_keys an."
  touch "$AUTH_KEYS"
else
  echo "$PUBKEY" > "$AUTH_KEYS"
fi

chown "$ADMIN_USER:$ADMIN_USER" "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

# 4) SSH-Hardening als Config-Snippet
cat << 'EOF' >/etc/ssh/sshd_config.d/99-hardening.conf
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes

AllowGroups ssh-users
AuthorizedKeysFile .ssh/authorized_keys
EOF

# 5) Config testen und sshd neu starten
sshd -t
systemctl restart sshd
echo "SSH-Hardening fertig. Erlaubte Gruppe: ssh-users"
echo "Public Key wurde in $AUTH_KEYS geschrieben."

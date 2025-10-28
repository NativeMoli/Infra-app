#!/bin/bash
set -euo pipefail

# -----------------------
# Конфігурація
# -----------------------
BASTION_PUBLIC="34.77.91.241"   # публічний IP Bastion
BASTION_PRIVATE="192.168.0.2"   # приватний IP Bastion для внутрішніх підключень
JENKINS_HOST="192.168.0.66"     # приватний IP Jenkins
WEB_HOST="192.168.0.67"         # приватний IP Web
SSH_USER="ubuntu"
JENKINS_KEY_PATH="/var/lib/jenkins/.ssh/jenkins_rsa"

echo "🚀 Починаємо налаштування Jenkins SSH ключів..."

# -----------------------
# 0) Очищаємо старі known_hosts
# -----------------------
ssh-keygen -R "${BASTION_PUBLIC}" || true
ssh-keygen -R "${BASTION_PRIVATE}" || true
ssh-keygen -R "${JENKINS_HOST}" || true
ssh-keygen -R "${WEB_HOST}" || true

# -----------------------
# 1) Генеруємо ключ на Jenkins (перезаписуємо)
# -----------------------
ssh -o StrictHostKeyChecking=no -J "${SSH_USER}@${BASTION_PUBLIC}" "${SSH_USER}@${JENKINS_HOST}" bash -s <<'REMOTE'
set -euo pipefail

JENKINS_SSH_DIR="/var/lib/jenkins/.ssh"
KEY_PATH="$JENKINS_SSH_DIR/jenkins_rsa"

sudo mkdir -p "$JENKINS_SSH_DIR"
sudo chmod 700 "$JENKINS_SSH_DIR"

if id -u jenkins >/dev/null 2>&1; then
    OWNER="jenkins:jenkins"
else
    OWNER="ubuntu:ubuntu"
fi
sudo chown -R $OWNER "$JENKINS_SSH_DIR"

# Перезаписуємо ключ
sudo rm -f "$KEY_PATH" "$KEY_PATH.pub"
if id -u jenkins >/dev/null 2>&1; then
    sudo -u jenkins ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -q
else
    sudo ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -q
fi

sudo chmod 600 "$KEY_PATH"
sudo chmod 644 "$KEY_PATH.pub"
sudo chown $OWNER "$KEY_PATH" "$KEY_PATH.pub"

# Додаємо Jenkins в Docker і перезапускаємо службу
if id -u jenkins >/dev/null 2>&1; then
    echo "⚙️  Додаємо Jenkins в групу docker та перезапускаємо службу Jenkins..."
    sudo usermod -aG docker jenkins
    sudo systemctl restart jenkins
fi
REMOTE

# -----------------------
# 2) Зчитуємо публічний ключ Jenkins
# -----------------------
echo "🔎 Читаємо публічний ключ Jenkins..."
PUB_KEY=$(ssh -o StrictHostKeyChecking=no -J "${SSH_USER}@${BASTION_PUBLIC}" "${SSH_USER}@${JENKINS_HOST}" "sudo cat ${JENKINS_KEY_PATH}.pub")

echo "🔑 Публічний ключ Jenkins:"
echo "${PUB_KEY}"
echo ""

# -----------------------
# 3) Додаємо ключ у Bastion
# -----------------------
ssh -o StrictHostKeyChecking=no "${SSH_USER}@${BASTION_PUBLIC}" bash -s <<EOF
set -euo pipefail
mkdir -p ~/.ssh
chmod 700 ~/.ssh
grep -qxF "${PUB_KEY}" ~/.ssh/authorized_keys || echo "${PUB_KEY}" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
EOF

# -----------------------
# 4) Додаємо ключ у Web через Bastion
# -----------------------
ssh -o StrictHostKeyChecking=no -J "${SSH_USER}@${BASTION_PUBLIC}" "${SSH_USER}@${WEB_HOST}" bash -s <<EOF
set -euo pipefail
mkdir -p ~/.ssh
chmod 700 ~/.ssh
grep -qxF "${PUB_KEY}" ~/.ssh/authorized_keys || echo "${PUB_KEY}" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
EOF

# -----------------------
# 5) Перевірки підключень Jenkins → Bastion та Jenkins → Web
# -----------------------
echo ""
echo "🧪 Перевірка: Jenkins → Bastion"
ssh -o StrictHostKeyChecking=no -J "${SSH_USER}@${BASTION_PUBLIC}" "${SSH_USER}@${JENKINS_HOST}" bash -s <<EOF
set -euo pipefail
KEY="${JENKINS_KEY_PATH}"
if id -u jenkins >/dev/null 2>&1; then
  sudo -u jenkins ssh -i "\$KEY" -o StrictHostKeyChecking=no -o BatchMode=yes ${SSH_USER}@${BASTION_PRIVATE} "echo '✅ Jenkins → Bastion OK'"
fi
EOF

echo ""
echo "🧪 Перевірка: Jenkins → Web (через Bastion)"
ssh -o StrictHostKeyChecking=no -J "${SSH_USER}@${BASTION_PUBLIC}" "${SSH_USER}@${JENKINS_HOST}" bash -s <<EOF
set -euo pipefail
KEY="${JENKINS_KEY_PATH}"
if id -u jenkins >/dev/null 2>&1; then
  sudo -u jenkins ssh -i "\$KEY" -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i \$KEY -W %h:%p ${SSH_USER}@${BASTION_PRIVATE}" -o BatchMode=yes ${SSH_USER}@${WEB_HOST} "echo '✅ Jenkins → Web OK'"
fi
EOF

echo ""
echo "🎉 Готово — ключ встановлено, Jenkins у групі Docker, служба перезапущена!"

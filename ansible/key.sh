#!/bin/bash
# Автоматичне додавання ключа на внутрішні хости через bastion
# Очищує старі ключі з known_hosts, додає нові та перевіряє підключення

BASTION_USER=ubuntu
BASTION_HOST=34.78.193.240

INTERNAL_HOSTS=("192.168.0.66" "192.168.0.67")
SSH_KEY="$HOME/.ssh/id_rsa.pub"

# Переконаємося, що ключ існує
if [ ! -f "$SSH_KEY" ]; then
    echo "SSH ключ $SSH_KEY не знайдено. Генеруємо новий..."
    ssh-keygen -t rsa -b 4096 -f "${SSH_KEY%.*}" -N ""
fi

for HOST in "${INTERNAL_HOSTS[@]}"; do
    echo "-------------------------------"
    echo "Очищаємо старий ключ для $HOST..."
    ssh-keygen -R "$HOST" 2>/dev/null
    ssh-keygen -R "$HOST" -f "$HOME/.ssh/known_hosts" 2>/dev/null

    echo "Налаштовуємо ключ на $HOST через bastion $BASTION_HOST..."
    ssh-copy-id -i "$SSH_KEY" -o "ProxyJump=$BASTION_USER@$BASTION_HOST" ubuntu@$HOST

    echo "Перевірка підключення до $HOST через bastion..."
    ssh -o "ProxyJump=$BASTION_USER@$BASTION_HOST" ubuntu@$HOST "echo Підключення до $HOST успішне"
done

echo "-------------------------------"
echo "Усі ключі додані і підключення перевірено."

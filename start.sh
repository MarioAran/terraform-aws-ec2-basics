#!/bin/bash
# -------------------------------
# Script idempotente para instalar Docker y levantar Nginx
# Diseñado para user_data en EC2 Ubuntu
# -------------------------------

set -euo pipefail  # ⚡ Modo estricto: falla si hay error o variable no definida
LOG_FILE="/var/log/user_data.log"

echo "=== Iniciando script user_data ===" | tee -a $LOG_FILE

# 1️⃣ Actualizar sistema
echo "Actualizando paquetes..." | tee -a $LOG_FILE
apt update -y >> $LOG_FILE 2>&1
apt upgrade -y >> $LOG_FILE 2>&1

# 2️⃣ Instalar dependencias básicas
echo "Instalando dependencias (curl, ca-certificates)..." | tee -a $LOG_FILE
apt install -y curl ca-certificates >> $LOG_FILE 2>&1

# 3️⃣ Instalar Docker solo si no existe
if ! command -v docker &> /dev/null; then
    echo "Docker no encontrado, instalando..." | tee -a $LOG_FILE

    # Crear keyrings y agregar repositorio
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt update -y >> $LOG_FILE 2>&1
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> $LOG_FILE 2>&1

    # Iniciar y habilitar Docker
    systemctl start docker
    systemctl enable docker
else
    echo "Docker ya está instalado" | tee -a $LOG_FILE
fi

# 4️⃣ Levantar contenedor Nginx solo si no existe
CONTAINER_NAME="nginx_hello"
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Creando contenedor ${CONTAINER_NAME}..." | tee -a $LOG_FILE
    docker run -d -p 80:80 --name $CONTAINER_NAME nginx >> $LOG_FILE 2>&1
else
    echo "Contenedor ${CONTAINER_NAME} ya existe, arrancando si está parado..." | tee -a $LOG_FILE
    docker start $CONTAINER_NAME >> $LOG_FILE 2>&1
fi

# 5️⃣ Verificación final
echo "Verificando estado de Docker y contenedor..." | tee -a $LOG_FILE
docker --version | tee -a $LOG_FILE
docker ps | tee -a $LOG_FILE

echo "=== Script finalizado correctamente ===" | tee -a $LOG_FILE

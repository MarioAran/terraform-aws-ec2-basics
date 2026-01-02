#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/user_data.log"

echo "=== Iniciando script user_data ===" | tee -a $LOG_FILE

# 1️⃣ Actualizar sistema
echo "Actualizando paquetes..." | tee -a $LOG_FILE
apt update -y >> $LOG_FILE 2>&1
apt upgrade -y >> $LOG_FILE 2>&1

# 2️⃣ Instalar dependencias básicas
echo "Instalando dependencias (curl, ca-certificates, git)..." | tee -a $LOG_FILE
apt install -y curl ca-certificates git >> $LOG_FILE 2>&1

# 3️⃣ Instalar Docker solo si no existe
if ! command -v docker &> /dev/null; then
    echo "Docker no encontrado, instalando..." | tee -a $LOG_FILE

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

    systemctl start docker
    systemctl enable docker
else
    echo "Docker ya está instalado" | tee -a $LOG_FILE
fi

# 4️⃣ Clonar o actualizar proyecto desde GitHub
APP_DIR="/home/ubuntu/gym-app"
REPO_URL="https://github.com/MarioAran/Quadcodex_Team_Back.git"
CONTAINER_NAME="mega_gym_api"

if [ -d "$APP_DIR" ]; then
    echo "Actualizando proyecto..." | tee -a $LOG_FILE
    cd $APP_DIR
    git pull >> $LOG_FILE 2>&1
else 
    echo "Clonando proyecto..." | tee -a $LOG_FILE
    git clone $REPO_URL $APP_DIR >> $LOG_FILE 2>&1
    cd $APP_DIR
fi

# 5️⃣ Construir imagen Docker
echo "Construyendo imagen Docker..." | tee -a $LOG_FILE
docker build -t mega_gym_api . >> $LOG_FILE 2>&1

# 6️⃣ Ejecutar contenedor idempotente
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Arrancando contenedor..." | tee -a $LOG_FILE
    docker run -d -p 5000:5000 --name $CONTAINER_NAME mega_gym_api >> $LOG_FILE 2>&1
else
    echo "Contenedor ya existe, arrancando si está detenido..." | tee -a $LOG_FILE
    docker start $CONTAINER_NAME >> $LOG_FILE 2>&1
fi

# 7️⃣ Verificación final
echo "Verificando estado de Docker y contenedor..." | tee -a $LOG_FILE
docker --version | tee -a $LOG_FILE
docker ps | tee -a $LOG_FILE

echo "=== Script finalizado correctamente ===" | tee -a $LOG_FILE

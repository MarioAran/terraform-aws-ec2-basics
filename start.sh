#!/bin/bash
set -euo pipefail

# Variables
APP_DIR="$HOME/wordpress"
DB_DIR="$APP_DIR/db_data"
WP_DIR="$APP_DIR/wordpress_data"
COMPOSE_FILE="$APP_DIR/docker-compose.yaml"
LOG_FILE="$APP_DIR/start.log"

echo "=== Iniciando script start.sh ===" | tee -a "$LOG_FILE"

# 1️⃣ Actualizar sistema e instalar dependencias
echo "Actualizando paquetes..." | tee -a "$LOG_FILE"
sudo apt update -y >> "$LOG_FILE" 2>&1
sudo apt upgrade -y >> "$LOG_FILE" 2>&1
sudo apt install -y curl git unzip >> "$LOG_FILE" 2>&1

# 2️⃣ Instalar Docker si no existe
if ! command -v docker &> /dev/null; then
    echo "Docker no encontrado, instalando..." | tee -a "$LOG_FILE"
    sudo apt install -y docker.io >> "$LOG_FILE" 2>&1
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker ya está instalado" | tee -a "$LOG_FILE"
fi

# 3️⃣ Instalar Docker Compose si no existe
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose no encontrado, instalando..." | tee -a "$LOG_FILE"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose ya está instalado" | tee -a "$LOG_FILE"
fi

# 4️⃣ Crear carpetas para volúmenes
mkdir -p "$DB_DIR" "$WP_DIR"
echo "Carpetas para volúmenes creadas en $APP_DIR" | tee -a "$LOG_FILE"

# 5️⃣ Crear docker-compose.yaml
cat > "$COMPOSE_FILE" <<EOF
version: '3.8'

services:
  db:
    image: mysql:8
    volumes:
      - $DB_DIR:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Passw0rd
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: Passw0rd

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    volumes:
      - $WP_DIR:/var/www/html
    ports:
      - "80:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: Passw0rd
      WORDPRESS_DB_NAME: wordpress
EOF

echo "docker-compose.yaml creado" | tee -a "$LOG_FILE"

# 6️⃣ Levantar contenedores
cd "$APP_DIR"
docker-compose up -d >> "$LOG_FILE" 2>&1
echo "Contenedores WordPress y MySQL levantados" | tee -a "$LOG_FILE"

# 7️⃣ Verificación final
docker ps | tee -a "$LOG_FILE"
echo "=== Script finalizado correctamente ===" | tee -a "$LOG_FILE"

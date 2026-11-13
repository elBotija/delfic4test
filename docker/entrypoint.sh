#!/bin/bash
set -e

DB_HOST=${DB_HOST:-mariadb}
DB_PORT=${DB_PORT:-3306}

echo "=== Iniciando Entorno Legacy Colegio (Delphi / MariaDB) ==="
echo "Esperando que el servidor de Base de Datos ($DB_HOST:$DB_PORT) este listo..."

while ! nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 1
done

echo "Base de Datos MariaDB detectada activa en $DB_HOST:$DB_PORT."

# Asegurar compilacion o actualizacion si se modifico el codigo fuente
echo "Compilando / actualizando proyecto ColegioLegacy con lazbuild..."
cd /app/src
lazbuild ColegioLegacy.lpr

echo "Iniciando aplicacion grafica ColegioLegacy en DISPLAY=:0..."
sleep 2

cd /app/src
exec ./ColegioLegacy

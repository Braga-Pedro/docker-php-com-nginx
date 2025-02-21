#!/bin/bash

# Função para exibir logs e evitar que o container finalize
trap "exit" SIGTERM SIGINT
set -e

echo "Aguardando banco de dados..."
until nc -z pgsql 5432; do
  sleep 1
  echo "Ainda aguardando banco de dados..."
done
echo "Banco de dados está pronto!"

# Instala dependências do frontend
npm install --peer-deps --force; npm run build

# Gera a chave da aplicação
php artisan key:generate

# Executa migrações e seeds
php artisan migrate --force
php artisan db:seed --force

# php artisan key:generate ; php artisan migrate --force; php artisan db:seed --force

# Inicia a fila (executada pelo supervisor)
echo "Iniciando supervisor..."
exec supervisord -c /etc/supervisor/supervisord.conf

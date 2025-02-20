ARG PHP_VERSION
FROM php:${PHP_VERSION}

## Diretório da aplicação | ALTERAR para o path local /app
ARG APP_DIR=/var/www/app 
# ARG APP_DIR=/home/pedro/projects/docker-php-com-nginx 

### apt-utils é um extensão de recursos do gerenciador de pacotes APT
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    apt-utils \ 
    supervisor

# dependências recomendadas de desenvolvido para ambiente linux
RUN apt-get update && apt-get install -y \
    libpq-dev \
    zlib1g-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    libsodium-dev \
    libpng-dev \
    libjpeg-dev \
    libonig-dev

RUN docker-php-ext-install pdo pdo_pgsql pgsql
RUN docker-php-ext-install curl zip gd fileinfo mbstring exif

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./docker/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# COPY ./docker/supervisord/conf /etc/supervisord.d/
COPY ./docker/php/extra-php.ini "$PHP_INI_DIR/99_extra.ini"
COPY ./docker/php/extra-php-fpm.conf /etc/php8/php-fpm.d/www.conf

WORKDIR $APP_DIR
RUN cd $APP_DIR
RUN chown www-data:www-data $APP_DIR

COPY --chown=www-data:www-data ./app .
RUN rm -rf vendor
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader


RUN apt-get install nginx -y
RUN rm -rf /etc/nginx/sites-enabled/* && rm -rf /etc/nginx/sites-available/*
COPY ./docker/nginx/sites.conf /etc/nginx/sites-enabled/default.conf
COPY ./docker/nginx/error.html /var/www/html/error.html

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Atualiza os pacotes antes de instalar
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg 

# Adiciona a chave GPG do repositório oficial do Node.js
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | tee /etc/apt/keyrings/nodesource.asc > /dev/null

# Adiciona o repositório do Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -

# Atualiza a lista de pacotes e instala o Node.js
RUN apt-get update && apt-get install -y nodejs

# Instala o Yarn globalmente
RUN npm install -g yarn 

# Copia entrypoint script e define permissões
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Comando para rodar supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
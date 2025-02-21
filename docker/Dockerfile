ARG PHP_VERSION
FROM php:${PHP_VERSION}

ARG APP_DIR=/var/www/app 
ARG REDIS_LIB_VERSION=5.3.7
# Atualiza pacotes e instala dependências necessárias
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    apt-utils \
    supervisor \
    libpq-dev \
    zlib1g-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    libsodium-dev \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    nginx \
    ca-certificates \
    curl \
    netcat \
    nano \
    git \
    gnupg

RUN pecl install redis-${REDIS_LIB_VERSION} -n 

# Instala extensões do PHP
RUN docker-php-ext-install pdo pdo_pgsql pgsql curl zip gd fileinfo mbstring exif
RUN docker-php-ext-enable redis

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Define diretório da aplicação
WORKDIR $APP_DIR
COPY --chown=www-data:www-data ./app .

# Instala dependências do PHP
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader

# Configura Nginx
RUN rm -rf /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*
COPY ./docker/nginx/sites.conf /etc/nginx/sites-enabled/default.conf
COPY ./docker/nginx/error.html /var/www/html/error.html

# Instala Node.js e Yarn
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | tee /etc/apt/keyrings/nodesource.asc > /dev/null
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y nodejs
RUN npm install -g yarn 

# Configura supervisor
COPY ./docker/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copia arquivos de configuração do PHP
COPY ./docker/php/extra-php.ini "$PHP_INI_DIR/99_extra.ini"
COPY ./docker/php/extra-php-fpm.conf /etc/php8/php-fpm.d/www.conf

# subir o frontend para receber as requisições
RUN npm install --peer-deps --force && npm run build

RUN chown -R www-data:www-data "$APP_DIR/public"
RUN chmod -R 755 "$APP_DIR/public"

# php artisan config:clear; php artisan cache:clear; php artisan config:cache

# remove mock service by production mode
RUN [ -f public/mockServiceWorker.js ] && rm public/mockServiceWorker.js || echo "mockServiceWorker não encontrado, ignorando..."

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

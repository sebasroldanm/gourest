FROM php:8.4-fpm-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    icu-dev \
    git \
    curl \
    unzip \
    linux-headers \
    autoconf \
    g++ \
    make

# Configurar extensiones de imagen
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

# Instalar extensiones de PHP
RUN docker-php-ext-install \
    pdo_mysql \
    opcache \
    zip \
    gd \
    intl \
    bcmath \
    pcntl

# Instalar Redis
RUN pecl install redis \
    && docker-php-ext-enable redis

# Instalar Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar directorio de trabajo
WORKDIR /var/www/html

# Crear usuario para Laravel
RUN addgroup -g 1000 laravel && \
    adduser -D -u 1000 -G laravel laravel

# Copiar configuración de PHP
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Cambiar permisos
RUN chown -R laravel:laravel /var/www/html

# Cambiar al usuario laravel
USER laravel

# Exponer puerto
EXPOSE 9000

CMD ["php-fpm"]
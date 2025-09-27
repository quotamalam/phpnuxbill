FROM php:8.2-apache

# Install tools & dependensi
RUN apt-get update && apt-get install -y \
    cron \
    unzip \
    curl \
    pkg-config \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Konfigurasi GD
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

# Install ekstensi PHP
RUN docker-php-ext-install -j$(nproc) \
    gd \
    mbstring \
    pdo \
    pdo_mysql \
    zip \
    xml

# Aktifkan mod_rewrite misalnya
RUN a2enmod rewrite

# Copy kode aplikasi
WORKDIR /var/www/html
COPY . /var/www/html

# Atur izin
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Setup cron
RUN echo "* * * * * www-data php /var/www/html/system/cron.php >> /var/log/cron.log 2>&1" > /etc/cron.d/phpnuxbill \
    && chmod 0644 /etc/cron.d/phpnuxbill \
    && crontab /etc/cron.d/phpnuxbill

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]

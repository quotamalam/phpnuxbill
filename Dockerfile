FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cron \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    unzip \
    curl \
    nano \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    unzip \
    curl \
    cron \
    && docker-php-ext-install gd mbstring pdo pdo_mysql zip xml


# Enable Apache modules
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Set up cron job
RUN echo "* * * * * www-data php /var/www/html/system/cron.php >> /var/log/phpnuxbill_cron.log 2>&1" > /etc/cron.d/phpnuxbill \
    && chmod 0644 /etc/cron.d/phpnuxbill \
    && crontab /etc/cron.d/phpnuxbill

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]

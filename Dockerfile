FROM php:8.0-fpm-alpine
RUN apk add --no-cache mysql-client msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu icu-data-full

# Upstream backport for EOL 8.0: https://github.com/php/php-src/commit/82f8f31b16a035c1b67cc253e79f7cc288f4cc20
COPY patches/CVE-2026-109618-109619.patch /tmp/
RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev \
    $PHPIZE_DEPS patch argon2-dev coreutils curl-dev gnu-libiconv-dev libsodium-dev libxml2-dev \
    linux-headers oniguruma-dev openssl-dev readline-dev sqlite-dev && \
    ln -sf gnu-libiconv/iconv.h /usr/include/iconv.h && \
    docker-php-source extract && \
    cd /usr/src/php && patch -p1 < /tmp/CVE-2026-109618-109619.patch && \
    eval "./configure $(php-config --configure-options) CFLAGS='$PHP_CFLAGS' CPPFLAGS='$PHP_CPPFLAGS' LDFLAGS='$PHP_LDFLAGS'" && \
    make -j "$(nproc)" && make install && \
    (find /usr/local/bin /usr/local/sbin -type f -perm '/0111' -exec strip --strip-all '{}' + 2>/dev/null || true) && \
    cd / && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install intl && \
    docker-php-ext-install opcache && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    apk del build-essentials && rm -rf /usr/src/php* /tmp/*.patch

RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer

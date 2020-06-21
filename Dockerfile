FROM wordpress:php7.4-apache AS builder

RUN set -eux; \
	apt-get update; \
	apt-cache search php dev; \
	apt-get install -y --no-install-recommends \
		golang curl libcurl4-openssl-dev git unzip\
	;
#	rm -rf /var/lib/apt/lists/*

RUN mkdir /build && cd /build && curl -skSL https://github.com/SkyAPM/SkyAPM-php-sdk/archive/v3.3.2.tar.gz | tar -xzC /build --strip 1
RUN cd /build && phpize && ./configure && make && make install \
  && go build -o /usr/local/bin/sky-php-agent ./cmd/main.go
#/build/modules/skywalking.so
RUN ls -l /usr/src/ \
  && echo $PHP_INI_DIR \
  && cp /build/php.ini $PHP_INI_DIR/conf.d/ext-skywalking.ini \
  && curl -skSL https://downloads.wordpress.org/plugin/woocommerce.4.2.0.zip -o /usr/src/wordpress/wp-content/plugins/woocommerce.4.2.0.zip \
  && cd /usr/src/wordpress/wp-content/plugins/ && unzip woocommerce.4.2.0.zip && rm -f woocommerce.4.2.0.zip
    

FROM wordpress:php7.4-apache

COPY --from=builder /build/modules/skywalking.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/skywalking.so
COPY --from=builder /build/php.ini /usr/local/etc/php/conf.d/ext-skywalking.ini
COPY --from=builder /usr/local/bin/sky-php-agent /usr/local/bin/
COPY --from=builder /usr/src/wordpress/wp-content/plugins/woocommerce /usr/src/wordpress/wp-content/plugins/

ADD entrypoint.sh /usr/local/bin

VOLUME /var/www/html
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]

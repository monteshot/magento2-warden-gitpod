#!/bin/bash

read -t 30 -p "Do you want to deploy the database? (Y(default)/n): " answer
# Set default answer to "y" if no input is provided within 30 seconds
answer="${answer:-y}"

if [[ $answer == "y" || $answer == "Y" ]]; then
    echo "Installing the Magento to the DB..."
    clear_url=$(gp url | awk -F"//" {'print $2'}) && url=$url;
    warden env exec php-fpm bin/magento setup:install \
                            --base-url=$clear_url \
                            --db-host=db \
                            --db-name=magento \
                            --db-user=magento \
                            --db-password=magento \
                            --admin-firstname=admin \
                            --admin-lastname=admin \
                            --admin-email=admin@admin.com \
                            --admin-user=admin \
                            --admin-password=admin123 \
                            --language=en_US \
                            --currency=UAH \
                            --timezone=Europe/Kiev \
                            --use-rewrites=1 \
                            --search-engine=opensearch \
                            --opensearch-host=opensearch \
                            --opensearch-port=9200 \
                            --opensearch-index-prefix=magento2 \
                            --opensearch-timeout=15 \
                            --session-save=redis \
                            --session-save-redis-host=redis \
                            --session-save-redis-port=6379 \
                            --session-save-redis-db=2 \
                            --session-save-redis-max-concurrency=20 \
                            --cache-backend=redis \
                            --cache-backend-redis-server=redis \
                            --cache-backend-redis-db=0 \
                            --cache-backend-redis-port=6379 \
                            --page-cache=redis \
                            --page-cache-redis-server=redis \
                            --page-cache-redis-db=1 \
                            --page-cache-redis-port=6379

   warden env exec -e TRAEFIK_DOMAIN="$TRAEFIK_DOMAIN" php-fpm bin/magento config:set --lock-env web/unsecure/base_url \
         "https://${TRAEFIK_DOMAIN}/"

   warden env exec -e TRAEFIK_DOMAIN="$TRAEFIK_DOMAIN" php-fpm bin/magento config:set --lock-env web/secure/base_url \
         "https://${TRAEFIK_DOMAIN}/"
   warden env exec php-fpm bin/magento config:set --lock-env web/secure/offloader_header X-Forwarded-Proto
   warden env exec php-fpm bin/magento config:set --lock-env web/secure/use_in_frontend 1
   warden env exec php-fpm bin/magento config:set --lock-env web/secure/use_in_adminhtml 1
   warden env exec php-fpm bin/magento config:set --lock-env web/seo/use_rewrites 1
   warden env exec php-fpm bin/magento indexer:reindex
   warden env exec php-fpm bin/magento cache:flush

   echo "Magento has been installed successfully."

else
    echo "The database deployment has been canceled."
fi

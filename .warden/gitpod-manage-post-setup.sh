#!/bin/bash

clear_url=$(gp url | awk -F"//" {'print $2'}) && url=$url;


# Path to env.php
file_path="$GITPOD_REPO_ROOTS/app/etc/env.php"
echo $file_path
# Str for modifying
site1="clear\.magento2\.loc"

# If file exist
if [ -f "$file_path" ]; then

    sed -i "s|$site1|443-$clear_url|" "$file_path"
    echo "Modifying complete(env.php)."
    warden env exec php-fpm php bin/magento a:c:i
    warden env exec php-fpm php bin/magento s:up
    warden env exec php-fpm php bin/magento cache:enable
    warden env exec php-fpm php bin/magento d:m:se developer
else
    echo "File $file_path not found."
    exit 1
fi


#!/bin/bash
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

mage_port=2$(shuf -i 1000-9999 -n 1)
echo "Generating Magento at \"http://127.0.0.1:$mage_port/\""
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# if this command fails, the script will exit
mkdir mage-$mage_port

tar -xf magento-1.* --strip=1 -C mage-$mage_port
mkdir -p http-conf.d
cp http-blank.conf http-conf.d/mage-${mage_port}.conf
sed -i '/Define mage_port/s/mage_port .*/mage_port '${mage_port}'/' http-conf.d/mage-${mage_port}.conf
sed -i 's~root_path .*~root_path '${DIR}'~' http-conf.d/mage-${mage_port}.conf
echo 'CREATE DATABASE `mage-'${mage_port}'`;' | mysql -u root

if [ -f magento-sample-data-1.* ]; then
  tar -xf magento-sample-data-1.*.tar.bz2 --strip=1 -C mage-${mage_port} \
  magento-sample-data-*/media
  tar -xf magento-sample-data-1.*.tar.bz2 --strip=1 -C mage-${mage_port}/app/design\
  magento-sample-data-*/skin

  tar -Oxf magento-sample-data-1.*.tar.bz2 magento-sample-data-*/magento_sample_data_*.sql | \
  mysql -u root mage-${mage_port}
fi

find mage-$mage_port/app/etc -type d -exec chmod 770 {} \;
find mage-$mage_port/app/etc -type d -exec chgrp apache {} \;
find mage-$mage_port/media -type d -exec chmod 770 {} \;
find mage-$mage_port/media -type d -exec chgrp apache {} \;
find mage-$mage_port/media -type f -exec chmod 660 {} \;
find mage-$mage_port/media -type f -exec chgrp apache {} \;

php -f mage-$mage_port/install.php -- \
--license_agreement_accepted "yes" \
--locale "en_US" \
--timezone "America/New_York" \
--default_currency "USD" \
--db_host "localhost" \
--db_name "mage-${mage_port}" \
--db_user "root" \
--db_pass "" \
--url "http://127.0.0.1:${mage_port}" \
--skip_url_validation \
--use_rewrites "yes" \
--use_secure "no" \
--secure_base_url "" \
--use_secure_admin "no" \
--admin_firstname "Admin" \
--admin_lastname "User" \
--admin_email "admin@example.com" \
--admin_username "admin" \
--admin_password "password1" 1>/dev/null
echo " Done"

# Should ask for your password
sudo systemctl restart httpd.service

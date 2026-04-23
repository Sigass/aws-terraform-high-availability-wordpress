#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

retry() {
  local attempts="$1"
  shift
  local try=1
  until "$@"; do
    if [ "$try" -ge "$attempts" ]; then
      return 1
    fi
    try=$((try + 1))
    sleep 10
  done
}

retry 3 dnf install -y httpd php php-mysqlnd wget tar unzip
mkdir -p /var/www/html
cat > /var/www/html/health.html <<'HTML'
ok
HTML
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>WordPress setup in progress</title>
</head>
<body>
  <h1>WordPress setup in progress</h1>
  <p>The instance is bootstrapping. Refresh this page in a few minutes.</p>
</body>
</html>
HTML
chown -R apache:apache /var/www/html
systemctl enable --now httpd

cd /var/www/html
rm -f latest.tar.gz
retry 3 wget -O latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpressdb/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASS}/" wp-config.php
sed -i "s/localhost/${DB_HOST}/" wp-config.php
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
rm -f /var/www/html/index.html
chown -R apache:apache wp-content
systemctl restart httpd

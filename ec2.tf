data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_template" "wp_lt" {
  name_prefix            = "wordpress-ec2"
  image_id               = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  dynamic "iam_instance_profile" {
    for_each = var.enable_wordpress_s3_iam_resources ? [1] : []

    content {
      name = aws_iam_instance_profile.wordpress_ec2_profile[0].name
    }
  }

  user_data = base64encode(<<-EOF
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

    retry 3 dnf install -y httpd

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

    cat > /usr/local/bin/bootstrap-wordpress.sh <<'SCRIPT'
#!/bin/bash
set -euxo pipefail
exec >> /var/log/bootstrap-wordpress.log 2>&1

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

cd /var/www/html
retry 3 dnf install -y php php-mysqlnd wget tar unzip
rm -f latest.tar.gz
retry 3 wget -O latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpressdb/" wp-config.php
sed -i "s/username_here/${var.db_username}/" wp-config.php
sed -i "s/password_here/${var.db_password}/" wp-config.php
sed -i "s/localhost/${aws_db_instance.wordpress_db.address}/" wp-config.php
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

if [ "${var.enable_wordpress_s3_iam_resources}" = "true" ]; then
  sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i define( 'S3_UPLOADS_BUCKET', '${data.aws_s3_bucket.wordpress_storage.bucket}' );" wp-config.php
  sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i define( 'S3_UPLOADS_REGION', '${var.region}' );" wp-config.php

  mkdir -p wp-content/mu-plugins
  retry 3 wget -O /tmp/s3-uploads.zip https://codeload.github.com/humanmade/S3-Uploads/zip/refs/heads/master
  unzip -o /tmp/s3-uploads.zip -d /tmp
  rm -rf wp-content/mu-plugins/s3-uploads
  mv /tmp/S3-Uploads-master wp-content/mu-plugins/s3-uploads
  cat > wp-content/mu-plugins/s3-uploads-loader.php <<'PHP'
<?php
require WPMU_PLUGIN_DIR . '/s3-uploads/s3-uploads.php';
PHP
fi

rm -f /var/www/html/index.html
chown -R apache:apache wp-content
systemctl restart httpd
SCRIPT

    chmod +x /usr/local/bin/bootstrap-wordpress.sh
    nohup /usr/local/bin/bootstrap-wordpress.sh &
  EOF
  )
}
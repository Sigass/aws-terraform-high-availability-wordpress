resource "aws_launch_template" "wp_lt" {
  name_prefix            = "wordpress-ec2"
  image_id               = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.wordpress_ec2_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y httpd php php-mysqlnd wget tar unzip
    systemctl enable --now httpd
    cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* .
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/wordpressdb/" wp-config.php
    sed -i "s/username_here/${var.db_username}/" wp-config.php
    sed -i "s/password_here/${var.db_password}/" wp-config.php
    sed -i "s/localhost/${aws_db_instance.wordpress_db.address}/" wp-config.php
    sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i define( 'S3_UPLOADS_BUCKET', '${data.aws_s3_bucket.wordpress_storage.bucket}' );" wp-config.php
    sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i define( 'S3_UPLOADS_REGION', '${var.region}' );" wp-config.php
    chown -R apache:apache /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;

    mkdir -p wp-content/mu-plugins
    wget -O /tmp/s3-uploads.zip https://codeload.github.com/humanmade/S3-Uploads/zip/refs/heads/master
    unzip -o /tmp/s3-uploads.zip -d /tmp
    rm -rf wp-content/mu-plugins/s3-uploads
    mv /tmp/S3-Uploads-master wp-content/mu-plugins/s3-uploads
    cat > wp-content/mu-plugins/s3-uploads-loader.php <<'PHP'
<?php
require WPMU_PLUGIN_DIR . '/s3-uploads/s3-uploads.php';
PHP

    chown -R apache:apache wp-content
    systemctl restart httpd
  EOF
  )
}
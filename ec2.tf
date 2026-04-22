resource "aws_launch_template" "wp_lt" {
  name_prefix            = "wordpress-ec2"
  image_id               = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y httpd php php-mysqlnd wget tar
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
    chown -R apache:apache /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
    systemctl restart httpd
  EOF
  )
}
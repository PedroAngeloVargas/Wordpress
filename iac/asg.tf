resource "aws_launch_template" "launch" {
  name                   = "template"
  vpc_security_group_ids = [aws_security_group.grupo_seguranca_privado_app.id]
  instance_type          = "t2.micro"
  image_id               = "AMI_AMAZONLINUX"
  user_data = base64encode(templatefile("${path.module}/userdatawordpress.sh", {
    WORDPRESS_DB_HOST     = aws_db_instance.default.endpoint,
    WORDPRESS_DB_NAME     = aws_db_instance.default.db_name,
    WORDPRESS_DB_USER     = aws_db_instance.default.username,
    WORDPRESS_DB_PASSWORD = aws_db_instance.default.password,
    EFS_ID                = aws_efs_file_system.fileserver.id,
  }))
  key_name = aws_key_pair.chave.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name       = "Projeto Wordpress"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name       = "Projeto Wordpress"
    }
  }


  depends_on = [ aws_efs_mount_target.target_fileserver_1, aws_efs_mount_target.target_fileserver_2 ]
}

resource "aws_autoscaling_group" "asg" {

  depends_on          = [aws_db_instance.default, aws_efs_file_system.fileserver, aws_efs_mount_target.target_fileserver_1, aws_efs_mount_target.target_fileserver_2]
  name_prefix         = "ASG-Para-Alta-Disnobilidade"
  vpc_zone_identifier = [aws_subnet.minha_subnet_privada_app.id, aws_subnet.minha_subnet_privada_app_2.id]
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupTotalInstances"
  ]
  target_group_arns         = [aws_lb_target_group.health-check.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.launch.id
    version = "$Latest"
  }


}

resource "aws_autoscaling_policy" "policy" {
  name                   = "Politica-para-aumento-carga"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
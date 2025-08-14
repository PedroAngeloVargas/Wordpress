resource "aws_sns_topic" "alerta" {
  name = "ALERTA-ERRO-NO-SERVICO"
}

resource "aws_sns_topic_subscription" "envio" {
  topic_arn = aws_sns_topic.alerta.arn
  protocol = "email"
  endpoint = var.email
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_alta" {
  alarm_name = "ASG-CPU-Alta"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2" #
  statistic   = "Average"  
  threshold   = 70.0       
  period      = 300
  alarm_description = "Alerta quando a média de CPU do ASG ultrapassa 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [aws_sns_topic.alerta.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_500_erros_elb" {
  alarm_name          = "ALB-ELB-5XX-Erros"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5            
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300           
  statistic           = "Sum"
  threshold           = 1            
  alarm_description   = "Alerta quando ALB retorna erros 5XX"

  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerta.arn]
}



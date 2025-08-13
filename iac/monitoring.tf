resource "aws_sns_topic" "alerta" {
  name = "ALERTA-ERRO-NO-SERVICO"
}

resource "aws_sns_topic_subscription" "envio" {
  topic_arn = aws_sns_topic.alerta.arn
  protocol = "email"
  endpoint = var.email
}

resource "aws_cloudwatch_metric_alarm" "alb_500_erros" {
  alarm_name          = "ALB-Erros-5XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alerta quando o ALB retorna muitos erros 5XX das VMS"

  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
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
  alarm_description   = "Alerta quando o próprio ALB retorna erros 5XX"

  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerta.arn]
}



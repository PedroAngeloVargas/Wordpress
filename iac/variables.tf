variable "username" {
  description = "usuario-rds"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "password-rds"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Endereço de e-mail para o SNS"
  type        = string
  default     = "seu.email@exemplo.com" 
}

variable "meu_ip" {
  description = "Endereço IP em formato CIDR (ex: 192.168.1.5/32)"
  type        = list(string)
  default     = ["SEU_IP/32"]
}

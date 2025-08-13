
resource "aws_vpc" "minha_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true 
  enable_dns_hostnames = true 

  tags = {
    Name = "vpc"
  }
}

resource "aws_eip" "ip1" {
  domain = "vpc"

  tags = {
    Name = "IP_Elastico1"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "Internet_Gateway"
  }

}

resource "aws_nat_gateway" "meu_nat_app" {
  allocation_id = aws_eip.ip1.id
  subnet_id     = aws_subnet.minha_subnet_publica1.id


  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "NAT1"
  }

}


resource "aws_subnet" "minha_subnet_publica1" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_publica1"
  }

}

resource "aws_subnet" "minha_subnet_publica2" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_publica2"
  }

}

resource "aws_subnet" "minha_subnet_privada_app" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "subnet_privada1"
  }
}

resource "aws_subnet" "minha_subnet_privada_data" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet_privada2"
  }

}

resource "aws_subnet" "minha_subnet_privada_app_2" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.101.0/24" 
  availability_zone = "us-east-1b"    
  tags = {
    Name = "subnet_privada_app_2"
  }
}

resource "aws_subnet" "minha_subnet_privada_data_2" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.201.0/24" 
  availability_zone = "us-east-1b"    

  tags = {
    Name = "subnet_privada_data_2"
  }
}


resource "aws_route_table" "tabela_rotas_publica" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "Tabelo_Rotas_Publica"
  }
}

resource "aws_route_table" "tabela_rotas_privada_app" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.meu_nat_app.id
  }


  tags = {
    Name = "Tabelo_Rotas_Privada_App"
  }
}

resource "aws_route_table" "tabela_rotas_privada_data" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "Tabelo_Rotas_Privada_Data"
  }
}

resource "aws_route_table_association" "publica_associacao1" {
  subnet_id      = aws_subnet.minha_subnet_publica1.id
  route_table_id = aws_route_table.tabela_rotas_publica.id
}

resource "aws_route_table_association" "publica_associacao2" {
  subnet_id      = aws_subnet.minha_subnet_publica2.id
  route_table_id = aws_route_table.tabela_rotas_publica.id
}

resource "aws_route_table_association" "privada_associacao_app" {
  subnet_id      = aws_subnet.minha_subnet_privada_app.id
  route_table_id = aws_route_table.tabela_rotas_privada_app.id
}

resource "aws_route_table_association" "privada_associacao_data" {
  subnet_id      = aws_subnet.minha_subnet_privada_data.id
  route_table_id = aws_route_table.tabela_rotas_privada_data.id
}

resource "aws_route_table_association" "privada_associacao_app_2" {
  subnet_id      = aws_subnet.minha_subnet_privada_app_2.id
  route_table_id = aws_route_table.tabela_rotas_privada_app.id
}

resource "aws_route_table_association" "privada_associacao_data_2" {
  subnet_id      = aws_subnet.minha_subnet_privada_data_2.id
  route_table_id = aws_route_table.tabela_rotas_privada_data.id
}

resource "aws_security_group" "grupo_seguranca_publico" {
  name        = "acesso-alb"
  description = "Liberada porta 80 para web"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description = "HTTP para todos"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS para todos"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Security_Group_Acesso_Client"
  }
}

resource "aws_security_group" "grupo_seguranca_privado_app" {
  name        = "acesso-para-wordpress"
  description = "Liberada porta 80 para acesso do alb"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_publico.id]
  }

  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_publico.id]
  }

  ingress {
    description     = "SSH da bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_bastion.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Security_Group_Wordpress"
  }
}

resource "aws_security_group" "grupo_seguranca_rds" {
  name        = "acesso-rds"
  description = "Permite acesso MySQL a partir do wordpress"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_privado_app.id]
  }

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_bastion.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security_Group_Rds"
  }
}

resource "aws_security_group" "grupo_seguranca_efs" {
  name        = "acesso-efs"
  description = "Permite acesso NFS a partir das instancias da aplicacao"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_privado_app.id]
  }

  ingress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguranca_rds.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security_Group_Efs"
  }
}

resource "aws_security_group" "grupo_seguranca_bastion" {
  name        = "bastion-host"
  description = "Permite acesso SSH a partir de um IP publico especifico"
  vpc_id      = aws_vpc.minha_vpc.id

  ingress {
    description = "SSH para meu IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.meu_ip
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.meu_ip
  }

  ingress {
    description = "Dbeaver"
    from_port   = 8978
    to_port     = 8978
    protocol    = "tcp"
    cidr_blocks = var.meu_ip
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.meu_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_bastion"
  }
}
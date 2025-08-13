# Wordpress 🌐
Este é o segundo projeto desenvolvido como parte do programa de estágio AWS DevSecOps 2025 da Compass.Uol.

![Diagrama da Infraestrutura](https://raw.githubusercontent.com/PedroAngeloVargas/Wordpress/main/diagrama.jpg)

## 🔎 Sobre o Projeto
O objetivo principal deste projeto é a criação de uma infraestrutura de nuvem na AWS para hospedar uma página Wordpress em container. A infraestrutura foi configurada com uma infraestrutura de rede segura e com multiplas máquinas em uma subnet segura com autoscalling, Load Balancer e health-ckeck configurado.

Além disso, foi configurado uma bastion host para acesso SSH seguro as instâncias com soluções de monitoramento para o RDS, é também um checkout para indisponibilidade do ALB com status code 5XX mais notificação.

## 🚀 Tecnologias e Serviços Utilizados
O projeto foi construído utilizando os seguintes serviços e tecnologias:

### AWS:

- VPC (Virtual Private Cloud): Criação de uma rede virtual isolada para garantir um ambiente seguro e controlado.

- Subnets: Segmentação da VPC para organizar os recursos e controlar o fluxo de tráfego.

- EC2 (Elastic Compute Cloud): Provisionamento de servidores virtuais para hospedar a aplicação web.

- ALB (Aplication Loud Balancer): Balanceador de carga para as instâncias Wordpress.

- AGS (Auto Scalling Group): Grupo de aumento de escala para aumento de trafego, garantindo a disponibilidade da 
aplicação.

- EFS: Servidor de arquivos para garantir o compartilhamento dos recursos da aplicação entre as instâncias Wordpress.

- RDS: Servidor Mysql de alta disponibilidade.

- Security Group: Configuração de regras de firewall para controlar o tráfego de entrada e saída das instâncias EC2,
do RDS e da EFS.

- CloudWatch: Monitoramento do Load Balancer.

- SNS: Notificação ao proprietário de erros 5XX.

- User_data: Automação das configurações da Bastion Host e instâncias Wordpress

### Outros:

- Docker: Aplicação Wordpress em container + soluções de monitoramento do RDS

- Prometheus: Coletor de dados pull que fica "perguntando" a cada 15 segundos por métricas (dados de performance, status, etc.) do RDS.

- Grafana: Painel gráfico que se conecta ao Prometheus para buscar os dados que ele coletou e exibi-los em gráficos.

- Dbeaver: Client de Banco de dados universal para consutar os registros e tabelas do Mysql.

## 🎯 Funcionalidades Principais

- Hospedagem de Página Wordpress: Através do acesso do load balancer as instâncias na subnet privada, a página
é servida corretamente e com alta disponibilidade graças ao ASG. Os registros de dados, como os de usuário, são inseridos no RDS, e os objetos (videos, imagens e etc) são compartilhados pelo EFS.

- Monitoramento Ativo: Monitoramento do Rds e load balancer graças ao containers de monitoramento e ao Cloudwatch respectivamente.

- Notificações em Tempo Real: Alertas são enviados para um email.




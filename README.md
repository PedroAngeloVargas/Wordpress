# Wordpress 🌐
Este é o segundo projeto desenvolvido como parte do programa de estágio AWS DevSecOps 2025 da Compass.Uol.

![Diagrama da Infraestrutura](https://raw.githubusercontent.com/PedroAngeloVargas/Wordpress/main/diagrama.jpg)

## 🔎 Sobre o Projeto
O objetivo principal deste projeto é a criação de uma infraestrutura de nuvem na AWS para hospedar uma página Wordpress em container. A infraestrutura foi configurada com uma infraestrutura de rede segura e com multiplas máquinas em uma subnet segura com autoscalling, Load Balancer e health-ckeck configurado.

Além disso, foi configurado uma bastion host para acesso SSH seguro as instâncias com soluções de monitoramento para o RDS, é também um checkout para indisponibilidade do ALB com status code 5XX mais notificação.

## ⚡️ Sumário


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

- Docker: Container Runtime necessário para executar a aplicação.

- Wordpress: O WordPress é o sistema de gerenciamento de conteúdo mais popular do mundo, utilizado para criar e administrar sites na internet. É uma plataforma que permite que qualquer pessoa, mesmo sem conhecimento técnico de programação, possa construir, publicar e atualizar conteúdo online.

- Prometheus: Coletor de dados pull que fica "perguntando" a cada 15 segundos por métricas (dados de performance, status, etc.) do RDS.

- Grafana: Painel gráfico que se conecta ao Prometheus para buscar os dados que ele coletou e exibi-los em gráficos.

- Dbeaver: Client de Banco de dados universal para consutar os registros e tabelas do Mysql.

## 🎯 Funcionalidades Principais

- Hospedagem de Página Wordpress: Através do acesso do load balancer as instâncias na subnet privada, a página
é servida corretamente e com alta disponibilidade graças ao ASG. Os registros de dados, como os de usuário, são inseridos no RDS, e os objetos (videos, imagens e etc) são compartilhados pelo EFS.

- Monitoramento Ativo: Monitoramento do Rds e load balancer graças ao containers de monitoramento e ao Cloudwatch respectivamente.

- Notificações em Tempo Real: Alertas são enviados para um email.

## ☁️ Provisionamento da Infraestrutura 

### Pelo Terraform

1. Clone esse repositório (git clone (URL))

2. Baixe o Terraform, siga os passos da página oficial (https://developer.hashicorp.com/terraform/install)

3. Acesse o diretório do Terraform (Exemplo: /Wordpress/iac/)

4. É necessário gerar um par de chaves para acesso remoto. Abra o terminal no diretorio especificado acima, e digite:
    
    ```
    . ssh-keygen (Ao ser questionado pela primeira vez, insira o nome do par)
    ```

- Observação: Isso irá gerar um par de chaves unico .pem e .pub. Caso prefira utilizar o Putty para o acesso, é
necessário a conversão da chave, então digite:

    ```
    . puttygen minha_key.pem -o minha_key.ppk
    ```

5. Em /Wordpress/iac/bastion_host.tf procure por "public_key = file("./SUA_CHAVE.pub")"

6. Substitua pela nome de sua chave publica (Exemplo: minha_key.pub)

7. Adicionar seus atributos em variables.tf (email e IP)

8. Criar arquivo secret.tfvars em /Wordpress/iac

9. Adicionar atributos:

     ```
    . username = "nome_usuario_banco"

    . password = "senha_usuario_banco"
    ```

10. Para inicializar o state e baixar as configurações do provider, abra o terminal e digite:

    ```
    . terraform init 
    ```

11. Copie e cole suas credencias da AWS no terminal. Com a seguinte sintaxe de acordo com seu SO:

    ```
    . Linux | Mac

    . export AWS_ACCESS_KEY_ID="SUA_CHAVE_ACESSO"

    . export AWS_SECRET_ACCESS_KEY="SUA_CHAVE_SECRETA_ACESSO"

    . export AWS_SESSION_TOKEN="TOKEN_DE_SESSAO_SE_APLICAVEL"
    
    . Windows (CMD)

    . set AWS_ACCESS_KEY_ID="SUA_CHAVE_ACESSO"

    . set AWS_SECRET_ACCESS_KEY="SUA_CHAVE_SECRETA_ACESSO"

    . set AWS_SESSION_TOKEN="TOKEN_DE_SESSAO_SE_APLICAVEL"
    ```

12. Para fazer um plano de backup e visualizar todos os recursos criados, no terminal digite:
   
    ```
    . terraform plan -out plan.out
    ```

13. Ao visualizar os recursos e estiver de acordo, para executar, no terminal digite:

    ```
    . terraform apply plan.out
    ```

14. Será solicitado o nome de usuário do RDS e sua senha

15. Pronto, sua infraestrutura está provisionada utilizando o Terraform.

- Importante: Para destruir *TODOS* os recursos, caso queira, no terminal digite:

    ```
    . terraform destroy (Ao ser questionado, digite "yes" para concordar)
    ```

Opcional: Para acessar as maquinas Wordpress, faça o seguinte passo a passo:

    ```
    . 1. SFTP para a bastion host: sftp -i <sua_chava.pem> ubuntu@<ip_publico> 

    . 2. Encaminhe a sua chave .pem para a Bastion_Host com a sintaxe:
        put /caminho/para/sua/chave/maquina/local/chave.pem /home/ubuntu
    
    . 3. Ao finalizar o upload, agora faça um ssh: ssh -i <sua_chava.pem> ubuntu@<ip_publico>

    . 4. Dentro da Bastion Host, faça um novo SSH para uma das instâncias Wordpress utilizando o ip_privado delas:
        ssh -i <sua_chava.pem> ec2-user@<ip_privado>

    . 5. Visualize o container: docker ps

    . 6. Para conferir o compartilhamento dos recursos:
        cd /mnt/efs_wordpress
    ```

Opcional: Para acessar o painel de monitoramento, faça o seguinte passo a passo:

    ```
    . 1. Abra no brownser em http://<IP_publico_bastion>:3000

    . 2. 
    ```

### Pelo painel:

*--> Infraestrutura de Rede*

1. Abra o portal da AWS e faça o login, ou cadastre-se caso não tenha uma conta.

2. Para iniciar vamos começar provisionando uma infraestrutura de rede. Na barra de busca superior, digite VPC e selecione o serviço VPC.

3. Certifique-se de estar na região da AWS desejada (por exemplo, us-east-1, sa-east-1) no canto superior direito do console.

4. Crie a Virtual Private Cloud (VPC)

5. No painel de navegação esquerdo, clique em Suas VPCs.

6. Clique no botão Criar VPC.

7. Em Recursos a serem criados, selecione VPC e mais. Isso utilizará o assistente que facilita a criação dos recursos associados.

Configurações da VPC (Virtual Private Cloud):

    ```
    . Nome da tag - opcional: Dê um nome para sua VPC (ex: minha_vpc). Isso ajuda na identificação dos recursos.

    . Bloco CIDR IPv4: Defina o intervalo de IPs para sua VPC. Um bom começo é 10.0.0.0/16.
    ```

Configurações de sub-rede (Subnet):

    ```
    . Número de zonas de disponibilidade (AZs): Selecione 2. Isso garantirá alta disponibilidade.

    . Número de sub-redes públicas: Selecione 2. (Para o Load Balancer)

    . Número de sub-redes privadas: Selecione 4. (2 para a aplicação Wordpress e 2 para o RDS)

    . Blocos CIDR de sub-rede: O assistente irá sugerir uma divisão dos blocos CIDR. Você pode customizar se necessário (ex: 10.0.1.0/24, 10.0.2.0/24 para as públicas e 10.0.3.0/24, 10.0.4.0/24 para as privadas).
    ```

Internet Gateways (IGW):

    ```
    . Internet Gateway: Mantenha a opção Criar um internet gateway selecionada. O assistente irá criá-lo e associá-lo à VPC.

    . Deixe as outras opções com os valores padrão e clique em Criar VPC.

    . O assistente levará alguns instantes para criar e configurar todos os componentes. Ao final, você pode clicar em Visualizar VPC para ver os recursos criados.
    ```

8.  Criar o NAT Gatway na subnets publicas, com as tabelas de rotas privadas do Wordpress redirecionando o tráfego
para elas. Para isso, va em criar nat gatway e selecione a subnet publica 1, logo após de estar criado, va em tabelas de rotas e selecione as route tables referentes a subnet private 1 e 2. Va em rotas, editar rota, adicionar rota, e com 0.0.0.0/0 adicione a opção Gatway NAT. Deixe a primeira opção de rota como está.

9. Com a Infraestrutura de rede pronta, vamos provisionar os outros recursos.

10. Pronto, sua infraestrutura está provisionada utilizando o painel da AWS.

---

*--> Grupos de Segurança*

Resumo

1. Em VPC, no painel lateral, selecione Grupos de Segurança.

2. Selecione criar grupo de segurança.

3. Coloque um nome.

4. Selecione a VPC criada.

5. Selecione Regras de Entrada.

6. Regras de Saida no padrão.

- SG para o ALB
    
    ```
    . Entrada: HTTP | TCP | 80 | 0.0.0.0/0 - HTTPS | TCP | 443 | 0.0.0.0/0
    ```

- SG para a Bastion Host

    ```
    . Entrada: SSH | TCP | 22 | MEU_IP - Personalizado | TCP | 3000 | MEU_IP (Grafana) 
    . Personalizado | TCP | 9090 | MEU_IP (Prometheus) - Personalizado | TCP | 8978 | MEU_IP (Dbeaver)
    ```
- SG para o Wordpress
    
    ```
    . Entrada: SSH | TCP | 22 | SG-Bastion - HTTP | TCP | 80 | SG-ALB - HTTPS | TCP | 443 | SG-ALB
    ```

- SG para o RDS

    ```
    . Entrada: Mysql/Aurora | TCP | 3306 | SG-Bastion - Mysql/Aurora | TCP | 3306 | SG-Wordpress 
    ```

- SG para o EFS

    ```
    . Entrada: NFS | TCP | 2049 | SG-Wordpress
    ```
---

*--> Grupo de Sub-Redes*

1. Em RDS, no painel lateral, selecione Grupo de Sub-Redes.

2. Criar Criar grupo de sub-redes de banco de dados.

3. De um nome mais a descrição.

4. Escolha a vpc do projeto.

5. Seleciane as AZ (A e B).

6. Selecione ambas as Subnetes correspondentes ao RDS.

7. Criar.

---

*--> RDS*

1. Selecione o Aurora e RDS

2. Selecione Banco de dados

3. Criar Banco de Dados

4. Selecione Criação Padrão. A seguir, selecione:

5. Mysql

6. Nível Gratuito

7. Coloque uma senha forte

7. Instancia db.t3.micro

8. A VPC do projeto

9. Selecione o Grupo de Redes do passo anterior

10. Grupo de segurança do RDS

11. AZ preferencial, pode ser tanto A quanto B

12. Em configurança adicional, coloque o nome do Banco a ser criado.

13. O restante, deve permanecer no padrão.

---

*--> EFS*

1. No painel da AWS procure pelo serviço EFS.

2. Clique em Criar sistema de arquivos

3. Selecione perzonalizar

4. De um nome para o EFS

5. Selecione a VPC do projeto, onde as sub-redes estão localizadas

6. Deixe as outras opções como padrão

7. Na tabela "Destinos de montagem", você verá uma lista das Zonas de Disponibilidade (AZs) e sub-redes da sua VPC.

    ```
    . Para a primeira sub-rede privada wordpress.

    . Localize a linha correspondente a esta sub-rede.

    . Na coluna "Grupos de segurança", remova o grupo de segurança padrão e adicione o SG-EFS.
    
    . Para a segunda sub-rede privada wordpress.

    . Faça o mesmo: localize a linha da sub-rede.

    . Substitua o grupo de segurança padrão pelo seu grupo_seguranca_efs.
    ```

8. Va até a ultima página e clique em criar

---

*--> Bastion Host*

1. Acesse EC2 no painel da AWS

2. Dê um nome e escolha a imagem da aplicação (AMI):

    ```
    . Nome: Dê um nome para o seu servidor, por exemplo, bastion_host.

    . Imagens de aplicações e SO (AMI): Escolha a imagem do sistema operacional. Uma opção comum e funcional para o User_Data e essa aplicação é o Ubuntu. 
    ```

3. Escolha o Tipo de Instância:

    ```
    . Esta configuração define o poder de hardware (CPU, memória) do seu servidor.

    . Para manter-se no nível gratuito e para esta aplicação, selecione o tipo t2.micro, que suporta essa aplicação tranquilamente.
    ```

4. Crie um Par de Chaves para Acesso (Key Pair):

    ```
    . Este passo é crucial para que você possa se conectar ao servidor de forma segura via SSH.

    . Clique em Criar novo par de chaves.

    . Nome do par de chaves: Dê um nome, como minha_key.

    . Tipo de par de chaves: Mantenha RSA.

    . Formato do arquivo de chave privada: Selecione .pem se quiser fazer o acesso via Openssh ou .ppk 
    se quiser fazer via Putty.
    ```

5. Clique em Criar par de chaves. Seu navegador fará o download do arquivo de chave. Guarde este arquivo em um local seguro e nao compartilhe com ninguem! Além disso, você não poderá baixar novamente.

6. Configure as Definições de Rede:

    ```
    . No painel "Definições de Rede", clique em Editar.

    . VPC: Selecione a VPC do projeto.

    . Sub-rede: É fundamental escolher uma sub-rede pública. Selecione uma das sub-redes públicas do ALB

    . Atribuir IP público automaticamente: Verifique se esta opção está Habilitada.
    ```

7. Escolha o SG-Bastion.

8. Deixe os valores de armazenamento padrão.

9. Utilizar o User_Data para automatizar as configurações

    ```
    . Selecione detalhes avançados (Advanced details). Por padrão, ela pode estar recolhida. Clique nela para expandir.

    . Dentro do painel "Detalhes avançados" que se abriu, role um pouco para baixo até encontrar o campo de texto chamado Dados do usuário (User data).

    . Nesta caixa de texto você irá colar um script desse repositório. Que se encontra em /painel/userdatawordpress.sh

    . Não se esqueça, de definir as variáveis de ambiente do Banco de Dados corretament no arquivo:
        DB_HOST=":3306"
        DB_PASSWORD=""
        DB_USER=""
    ```

10. Criar instância.

---

*--> Launch Template*

1. Em EC2, selecione Modelos de Execução

2. Clique em Criar Modelo de Execução








# Wordpress 🌐
Este é o segundo projeto desenvolvido como parte do programa de estágio AWS DevSecOps 2025 da Compass.Uol.

![Diagrama da Infraestrutura](https://raw.githubusercontent.com/PedroAngeloVargas/Wordpress/main/diagrama.jpg)

---

## 🔎 Sobre o Projeto
O objetivo principal deste projeto é a criação de uma infraestrutura de nuvem na AWS para hospedar uma página Wordpress em container. A infraestrutura foi configurada com uma infraestrutura de rede segura e com multiplas máquinas em uma subnet segura com autoscalling, Load Balancer e health-ckeck configurado.

Além disso, foi configurado uma bastion host para acesso SSH seguro as instâncias com soluções de monitoramento para o RDS, é também um checkout para indisponibilidade do ALB com status code 5XX mais notificação.

---

## ⚡️ Sumário

**Índice**
* [Sobre o Projeto](#sobre-o-projeto)
* [Tecnologias Utilizadas](#tecnologias-e-servicos-utilizados)
* [Funcionalidades Principais](#funcionalidades-principais)
* [Provisionamento da Infraestrutura](#provisionamento-da-infraestrutura)
* [Monitoramento](#monitoramento)

---

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

---

### Outros:

- Docker: Container Runtime necessário para executar a aplicação.

- Wordpress: O WordPress é o sistema de gerenciamento de conteúdo mais popular do mundo, utilizado para criar e administrar sites na internet. É uma plataforma que permite que qualquer pessoa, mesmo sem conhecimento técnico de programação, possa construir, publicar e atualizar conteúdo online.

- Prometheus: Coletor de dados pull que fica "perguntando" a cada 15 segundos por métricas (dados de performance, status, etc.) do RDS.

- Grafana: Painel gráfico que se conecta ao Prometheus para buscar os dados que ele coletou e exibi-los em gráficos.

- Dbeaver: Client de Banco de dados universal para consutar os registros e tabelas do Mysql.

---

## 🎯 Funcionalidades Principais

- Hospedagem de Página Wordpress: Através do acesso do load balancer as instâncias na subnet privada, a página
é servida corretamente e com alta disponibilidade graças ao ASG. Os registros de dados, como os de usuário, são inseridos no RDS, e os objetos (videos, imagens e etc) são compartilhados pelo EFS.

- Monitoramento Ativo: Monitoramento do Rds e load balancer graças ao containers de monitoramento e ao Cloudwatch respectivamente.

- Notificações em Tempo Real: Alertas são enviados para um email.

---

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

---

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
        DB_HOST=""
        DB_PASSWORD=""
        DB_USER=""
    ```

10. Criar instância.

---

*--> Launch Template*

1. Em EC2, selecione Modelos de Execução

2. Clique em Criar Modelo de Execução

3. Dê um Nome e Descrição ao Modelo

    ```
    . Nome do modelo de execução: Dê um nome claro e descritivo. 

    . Descrição: Template da VM Wordpress.

    . Orientação do Auto Scaling: Marque a caixa de seleção Fornecer orientação para me ajudar a configurar um modelo para uso com o Amazon EC2 Auto Scaling. Isso ajuda a destacar os campos mais importantes.
    ````
    
4. Selecione a AMI (Imagem de Máquina)

    ```
    . Esta é a imagem do sistema operacional que suas instâncias usarão.

    . Na seção "Amazon Machine Image (AMI)", procure por Amazon Linux e selecione.

    . Certifique-se de que a AMI selecionada tenha a arquitetura correta (ex: 64 bits x86).
    ```

5. Escolha o Tipo de Instância

Aqui você define o poder de processamento e a memória da sua máquina.

    ````
    . Na seção "Tipo de instância", selecione um tipo na lista, uma boa escolha é a t2.micro ou t3.micro.
    ```

6. Associe um Par de Chaves (Key Pair)

    ```
    . Na seção "Par de chaves (login)", selecione um par de chaves .pem ou .ppk que você já tenha criado e baixado.
    ```

7. Configure a Rede (Security Group)

    ```
    . Em "Configurações de rede", na seção "Grupos de segurança", selecione SG-Wordpress.

    . Deixe o campo "Sub-rede" em branco ("Não incluir no modelo"). Isso dá mais flexibilidade para o Auto Scaling Group.
    ```

8. Configure o Armazenamento (Volumes)
    
    ```
    . A seção "Configurar armazenamento" já virá preenchida com o volume raiz (o disco principal) baseado na AMI que você escolheu, é o suficiente para a aplicação.
    ```

9. Adicione o Script de User Data

    ```
    . Expanda a seção "Detalhes avançados" no final da página.

    . Role até o final da seção expandida e encontre o campo "Dados do usuário".

    . Insira o arquivo /painel/userdatawordpress.sh, não se esqueça de colocar as variaveis de ambiente:
        EFS_ID=""
        DB_HOST=""
        DB_NAME=""
        DB_PASSWORD=""
        DB_USER=""
    ```

10. Criar Modelo de Execução
````
---

*--> Target Group (Health Check)*

1. No painel da AWS, vá para o serviço EC2.

2. No menu à esquerda, em "Balanceamento de Carga", clique em Grupos de destino (Target Groups).

3.  Clique no botão "Criar grupo de destino".

4.  Escolha um tipo de destino: Selecione "Instâncias". 

5. Nome do grupo de destino: Digite health-check.

6. Protocolo e Porta: Deixe como HTTP e a porta como 80 (correspondente a protocol e port).

7. PC: Selecione a VPC correta do projeto na lista.

8. Configurações da Verificação de Saúde (Health Check)

    ```
    . Protocolo da verificação de saúde: Mantenha como HTTP.

    . Caminho da verificação de saúde: Use / (correspondente a path).

    . Clique em "Configurações avançadas da verificação de saúde" para expandir e ver todas as opções.

        Porta: Deixe como "Porta de tráfego", que usará a porta 80 definida acima.

        Limite íntegro: Digite 3. 

        Limite não íntegro: Digite 3. 

        Intervalo: Digite 30 segundos.

        Códigos de sucesso: Clique em "Editar" e digite 200-322.
    ```

9. Clique em "Avançar" no canto inferior direito

10. Clique no botão "Criar grupo de destino" na parte inferior da página de resumo.

---

*--> Elastic Load Balancer*

1. No painel da AWS, vá para o serviço EC2.

2. No menu à esquerda, em "Balanceamento de Carga", clique em Load Balancers.

3. Clique no botão "Criar Load Balancer".

4. Escolher o Tipo de Load Balancer

    ```
    . Localize a caixa "Application Load Balancer" e clique em "Criar" dentro dela.
    ```

5. Configuração Básica

    ```
    . Nome do Load Balancer: Digite meualb.

    . Esquema: Selecione "Voltado para a Internet". 

    . Tipo de endereço IP: Deixe como "IPv4".
    ```

6. Mapeamento de Rede

    ```
    . VPC: Selecione a VPC correta do projeto onde suas sub-redes foram criadas.

    . Mapeamentos: Marque a caixa de seleção para as duas sub-redes públicas, uma para cada Zona de Disponibilidade.
    ```

7. Grupos de Segurança e Ouvintes

    ```
    . Grupos de segurança: Remova o security group "padrão", em seguida, selecione o SG-ALB na lista.

    . Ouvintes e roteamento: 

        Deixe o protocolo como HTTP e a porta como 80.

        Na "Ação padrão", clique em "Criar grupo de destino", selecione o health-ckeck.
    ```

8. Role até o final da página de resumo e desmarque a opção "Proteção contra exclusão".

9. Clique em "Criar Load Balancer".

---

*--> Auto Scalling Group*

1. No painel da AWS, vá para o serviço EC2.

2. No menu à esquerda, role para baixo até a seção "Auto Scaling" e clique em Grupos do Auto Scaling.

3. Clique no botão "Criar um grupo do Auto Scaling".

4. Escolher o Modelo e o Nome
    
    ```
    . Nome do grupo do Auto Scaling: Digite um nome.

    . Modelo de execução: Selecione na lista o Launch Template 
    ```

5. Configurar a Rede

    ```
    . VPC: Selecione a VPC correta do projeto.

    . Zonas de Disponibilidade e sub-redes: Selecione as duas sub-redes privadas wordpress na lista.
    ```

6. Anexar o Load Balancer e Verificações de Saúde

    ```
    Aqui você conecta o ASG ao Load Balancer e define as regras de saúde.

    . Selecione "Anexar a um grupo de destino de balanceador de carga existente".

    . Escolha na lista o Target Group health-check.

    . Na seção "Verificações de saúde (opcional)", marque a caixa de seleção para "Ativar verificações de integridade do Elastic Load Balancing".

    . No campo "Período de carência da verificação de saúde", digite 720 segundos.
    ```

7. Configurar Tamanho do Grupo e Política de Escalabilidade

    ```
    Esta é a tela onde você define tanto o tamanho do grupo quanto a política de escalabilidade.

    . Tamanho do grupo:

        Capacidade desejada: 1

        Capacidade mínima: 1

        Capacidade máxima: 1

    . Política de escalabilidade:

        Selecione "Política de escalabilidade de acompanhamento de destino".

        Tipo de métrica: Escolha "Utilização média da CPU".

        Valor de destino: Digite 70.
    ```
8. Clique no botão "Criar grupo do Auto Scaling".

---

*--> SNS*

1. No painel da AWS, vá para o serviço Simple Notification Service (SNS).

2. No menu à esquerda, clique em "Tópicos".

3. Clique em "Criar tópico".

4. Selecione o tipo "Padrão".

5. No campo Nome, de um nome descritivo.

6. Clique em "Criar tópico".

7. Criar a Inscrição por E-mail

    ```
    . Protocolo: Selecione "E-mail".

    . Endpoint: Digite o endereço de e-mail que deve receber os alertas.

    . Clique em "Criar inscrição".
    ```

8. Confirmar a Inscrição (Passo Essencial)

    ```
    . A AWS enviará um e-mail de confirmação para o endereço que você forneceu.

    . Abra seu e-mail e clique no link "Confirm Subscription". Sem isso, a inscrição ficará pendente e você não receberá os alertas.
    ```

---

*--> CloudWatch*

1. Vá para o serviço CloudWatch.

2. No menu à esquerda, clique em "Alarmes" e depois em "Todos os alarmes".

3. Clique em "Criar alarme".

4. Clique em "Selecionar métrica".

5. Navegue até ApplicationELB > "Por Balanceador de Carga".

6. Encontre seu Load Balancer na lista e selecione a métrica HTTPCode_ELB_5XX_Count.

7. Clique em "Selecionar métrica".

8. Configure as Condições:

    ```
    . Estatística: Soma.

    . Período: 5 minutos.

    . Limite: Defina a condição como "Maior/igual que" e o valor como 1.
    ```

9. Clique em "Avançar".

10. Configure a Ação:

    ```
    . Em "Ação de notificação", selecione "Selecionar um tópico do SNS existente".

    . Escolha o tópico SNS criado na lista.
    ```

11. Clique em "Avançar".

12. Adicione Nome e Descrição

13. Clique em "Avançar" e clique em "Criar alarme".

14. Para criar a métrica de uso de CPU para o ASG, volte em "Criar alarme".

15. Selecionar a Métrica Correta

    ```
    . Na tela "Especificar métrica e condições", clique em "Selecionar métrica".

    . A métrica CPUUtilization para um ASG está no namespace do EC2. Clique em EC2.

    . Agora você precisa filtrar pela dimensão correta. Clique em "Por grupo do Auto Scaling".

    . Você verá uma lista dos seus Auto Scaling Groups. Encontre o seu grupo (chamado asg no seu código) e marque a caixa de seleção ao lado da métrica CPUUtilization.
    ```

16. Clique no botão "Selecionar métrica".

17. Definir as Condições do Alarme

    ```
    . Estatística: Escolha Média (correspondente a statistic = "Average").

    . Período: Escolha 5 minutos (correspondente a period = 300).

    . Condições:

        Tipo de limite: Estático.

        Definir o alarme quando...: Selecione Maior/igual que (correspondente a comparison_operator).

        ...o limite: Digite 70 (correspondente a threshold = 70.0).
    ```

18. Clique em "Avançar".

19. Configurar a Ação de Notificação

    ```
    . Na seção "Ação de notificação", certifique-se de que o estado "Em alarme" está selecionado.

    . Selecione "Selecionar um tópico do SNS existente".

    . No campo "Enviar notificação para...", escolha o seu tópico SNS já existente (alerta).
    ```

20. Clique em "Avançar".

21. Adicionar Nome, Descrição e Criar

---

## 📊 Monitoramento

### Dbeaver

1. Acesse no browser http://<ip_publico_bastion>:8978.

2. No painel, va em Next.

3. Em "Administrator Credentials" crie um usuário e senha.

4. Ao criar o usuário, deverá fazer login com ele.

5. Estando logado, va no icone do Dbeaver no canto superior esquerdo.

6. Depois no icone de + e em "new connection".

7. Selecione Mysql

8. No painel:

    ```
    . Em Host coloque o endpoint do RDS.

    . Em Database o nome do Banco de Dados.

    . Em Authentication o nome e senha do usuário do Banco de Dados.

    . Criar conexão
    ```

9. Selecione o banco no menu lateral esquerdo e logue com o usuário.

10. O Dbeaver está configurado para manipular e consultar os dados.

---

### Grafana

1. Acesse no browser http://<ip_publico_bastion>:3000.

2. No painel de login, entre com o usuario padrão, depois por segurança troque a senha.

    ```
    . email or username = admin

    . password = admin
    ```

3. Ja no painel, no menu esquerdo, va em Dashboards.

4. Agora va em New > Import.

5. Em "Grafana.com dashboard URL ou ID" insira o numero 14031.

6. Clique em Load.

7. Em "Select Prometheus data source" escolha o Prometheus.

8. Clique em Import.

9. Os dashboard do Mysql são carregados.

---

## ✨ Sobre o Programa de Estágio

- Este projeto faz parte do Compass.Uol Schoolarship Program, que em parceria com universidades, oferece bolsas de estudo e oportunidades de aprendizagem para estudantes de tecnologia com excelente desempenho acadêmico, com foco em soluções de ponta e potencial de contratação.

---

## 👨‍💻 Autor

- Pedro Angelo Vargas

- GitHub: @PedroAngeloVargas











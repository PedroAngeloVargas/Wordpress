
resource "aws_key_pair" "chave" {
  key_name   = "Chave deploy"
  public_key = file("./deploy-key.pub")

}

resource "aws_instance" "vm_bastion" {
  depends_on                  = [aws_db_instance.default, aws_efs_file_system.fileserver]
  associate_public_ip_address = true
  ami                         = "AMI_DEBIAN/UBUNTU"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.chave.key_name
  subnet_id                   = aws_subnet.minha_subnet_publica2.id
  vpc_security_group_ids      = [aws_security_group.grupo_seguranca_bastion.id]


  user_data = base64encode(templatefile("${path.module}/userdatabastion.sh", {
    GF_SECURITY_ADMIN_USER     = "admin"
    GF_SECURITY_ADMIN_PASSWORD = "admin"
    MYSQL_EXPORTER_USER        = aws_db_instance.default.username,
    MYSQL_EXPORTER_PASSWORD    = aws_db_instance.default.password,
    MYSQL_EXPORTER_HOST        = aws_db_instance.default.endpoint,
  }))

  tags = local.common_tags

  root_block_device {
    tags = local.common_tags
  }
}


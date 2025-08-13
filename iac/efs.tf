resource "aws_efs_file_system" "fileserver" {

  tags = {
    Name = "meu-efs"
  }
}

resource "aws_efs_mount_target" "target_fileserver_1" {
  file_system_id  = aws_efs_file_system.fileserver.id
  subnet_id       = aws_subnet.minha_subnet_privada_app.id
  security_groups = [aws_security_group.grupo_seguranca_efs.id]
}

resource "aws_efs_mount_target" "target_fileserver_2" {
  file_system_id  = aws_efs_file_system.fileserver.id
  subnet_id       = aws_subnet.minha_subnet_privada_app_2.id
  security_groups = [aws_security_group.grupo_seguranca_efs.id]
}

resource "aws_efs_backup_policy" "backup-efs" {
  file_system_id = aws_efs_file_system.fileserver.id

  backup_policy {
    status = "ENABLED"
  }
}


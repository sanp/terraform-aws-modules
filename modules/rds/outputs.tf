output arn {
  value = aws_db_instance.db_instance.arn
}

output name {
  value = aws_db_instance.db_instance.name
}

output id {
  value = var.id
}

output address {
  value = aws_db_instance.db_instance.address
}

output port {
  value = aws_db_instance.db_instance.port
}

output master_username {
  sensitive = true
  value     = var.username
}

output master_password {
  sensitive = true
  value     = random_id.master_password.hex
}

output security_group_id {
  value = aws_security_group.rds_security_group.id
}

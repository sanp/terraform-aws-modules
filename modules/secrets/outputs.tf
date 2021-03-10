output name {
  value = aws_secretsmanager_secret.secret.name
}

output arn {
  value = aws_secretsmanager_secret.secret.arn
}

output kms_arn {
  value = aws_kms_key.kms_key.arn
}

output kms_id {
  value = aws_kms_key.kms_key.key_id
}

# Use KMS to encrypt secret values
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ${var.secret_name}."
  deletion_window_in_days = var.deletion_window_in_days
  tags = merge(
    var.base_tags,
    { "Secret" = var.secret_name }
  )
}

# Create a secret
resource "aws_secretsmanager_secret" "secret" {
  name                    = var.secret_name
  description             = var.secret_description
  kms_key_id              = aws_kms_key.kms_key.arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.base_tags,
    { "Name" = var.secret_name }
  )
}

# Store data in the secret
resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.secret)
}

resource "random_id" "master_password" {
  byte_length = var.password_length
}

# Use KMS to encrypt performance insights data
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ${var.name}."
  deletion_window_in_days = var.kms_deletion_window_in_days
  tags = merge(
    var.base_tags,
    { "DB" = var.name }
  )
}

# Security group for the RDS instance. Leave ingress and egress closed.
# Additional rules can be applied to the security group to grant access to
# specific apps.
resource "aws_security_group" "rds_security_group" {
  # Use name_prefix instead of name to force a destroy and replacement when
  # making changes to security group resources.
  name_prefix            = "${var.id}-security-group"
  description            = "Control access to the ${var.name} db instance."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.sg_revoke_rules_on_delete

  # Force create before destroy to avoid DependencyViolation errors when making
  # changes to security group resources. Note: interpolations are not allowed
  # inside of lifecycle blocks, so this must be hard-coded.
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.base_tags,
    { "DB" = var.name }
  )
}

# DB instance
resource "aws_db_instance" "db_instance" {
  name                                = var.name
  identifier                          = var.id
  allocated_storage                   = var.allocated_storage
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  backup_retention_period             = var.backup_retention_period
  instance_class                      = var.instance_class
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  username                            = var.username
  password                            = random_id.master_password.hex
  engine                              = var.engine
  port                                = var.port
  storage_type                        = var.storage_type
  engine_version                      = var.engine_version
  multi_az                            = var.multi_az
  storage_encrypted                   = var.storage_encrypted
  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = aws_kms_key.kms_key.arn
  deletion_protection                 = var.deletion_protection
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  vpc_security_group_ids              = [aws_security_group.rds_security_group.id]
  db_subnet_group_name                = var.db_subnet_group_name
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = "${var.id}-final-snapshot-${formatdate("DD-MMM-YYYY-hh-mm-ss-ZZZ", timestamp())}"

  lifecycle {
    ignore_changes = [
      # Ignore changes to the final snapshot name because it contains the
      # current timestamp, and so will be updated everytime a plan/apply is
      # run.
      final_snapshot_identifier,
    ]
  }

  tags = merge(
    var.base_tags,
    { "DB" = var.name }
  )
}

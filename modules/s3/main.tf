resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  acl           = var.acl
  force_destroy = var.force_destroy

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_algorithm
      }
    }
  }

  dynamic "object_lock_configuration" {
    for_each = range(var.object_lock_enabled ? 1 : 0)
    content {
      object_lock_enabled = "Enabled"
    }
  }

  tags = merge(
    var.base_tags,
    { "Name" = var.bucket_name }
  )
}

# Ensure that the S3 bucket is private
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Optionally upload files to the S3 bucket this module creates
resource "aws_s3_bucket_object" "bootstrap" {
  for_each = { for file in var.upload_files : file.s3_key => file }

  bucket        = aws_s3_bucket.bucket.bucket
  key           = each.value.s3_key
  source        = each.value.file_path
  etag          = filemd5(each.value.file_path)
  force_destroy = var.force_destroy

  object_lock_mode              = var.object_lock_mode
  object_lock_legal_hold_status = var.object_lock_legal_hold_status
  object_lock_retain_until_date = var.object_lock_retain_until_date
}

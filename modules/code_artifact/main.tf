locals {
  upstream_repository_name = "${var.repository_name}-upstream"
  tags = merge(
    var.base_tags,
    {
      "Domain"              = var.domain_name,
      "Repository"          = var.repository_name,
      "Upstream Repository" = local.upstream_repository_name,
    }
  )
}

# Use KMS to encrypt the artifacts
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ${var.domain_name}."
  deletion_window_in_days = var.kms_deletion_window_in_days
  tags                    = local.tags
}

##
# Domain
##

resource "aws_codeartifact_domain" "this_domain" {
  domain         = var.domain_name
  encryption_key = aws_kms_key.kms_key.arn
  tags           = local.tags
}

resource "aws_codeartifact_domain_permissions_policy" "this_domain_policy" {
  domain          = aws_codeartifact_domain.this_domain.domain
  policy_document = var.domain_policy
}

##
# Repository
##

# Upstream repository which is connected to a public external repository
resource "aws_codeartifact_repository" "this_repository_upstream" {
  repository = local.upstream_repository_name
  domain     = aws_codeartifact_domain.this_domain.domain
  tags       = local.tags

  external_connections {
    external_connection_name = "public:${var.external_upstream_connection}"
  }
}

# Repository for storing internal packages, which is downstream of the upstream
# repository.
resource "aws_codeartifact_repository" "this_repository" {
  repository = var.repository_name
  domain     = aws_codeartifact_domain.this_domain.domain
  tags       = local.tags

  upstream {
    repository_name = aws_codeartifact_repository.this_repository_upstream.repository
  }
}

# The same policy can be applied to both repositories.
resource "aws_codeartifact_repository_permissions_policy" "this_repository_policy" {
  repository      = aws_codeartifact_repository.this_repository.repository
  domain          = aws_codeartifact_domain.this_domain.domain
  policy_document = var.repository_policy
}

resource "aws_codeartifact_repository_permissions_policy" "this_repository_upstream_policy" {
  repository      = aws_codeartifact_repository.this_repository_upstream.repository
  domain          = aws_codeartifact_domain.this_domain.domain
  policy_document = var.repository_policy
}

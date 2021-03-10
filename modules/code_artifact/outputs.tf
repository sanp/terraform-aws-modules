output domain_arn {
  value = aws_codeartifact_domain.this_domain.arn
}

output domain_name {
  value = var.domain_name
}

output repository_arn {
  value = aws_codeartifact_repository.this_repository.arn
}

output repository_name {
  value = var.repository_name
}

output upstream_repository_arn {
  value = aws_codeartifact_repository.this_repository_upstream.arn
}

output upstream_repository_name {
  value = local.upstream_repository_name
}

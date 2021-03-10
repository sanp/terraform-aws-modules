output name {
  value = aws_dynamodb_table.table.name
}

output arn {
  value = aws_dynamodb_table.table.arn
}

output table_key {
  value = var.table_key
}

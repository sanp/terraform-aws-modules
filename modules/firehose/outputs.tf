output name {
  value = aws_kinesis_firehose_delivery_stream.extended_s3_stream.name
}

output arn {
  value = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}

output role_name {
  value = aws_iam_role.firehose_role.name
}

output role_arn {
  value = aws_iam_role.firehose_role.arn
}

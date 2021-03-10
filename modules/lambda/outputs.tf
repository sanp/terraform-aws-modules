output arn {
  value = aws_lambda_function.lambda.arn
}

output name {
  value = var.name
}

output security_group_id {
  value = (var.configure_vpc ? aws_security_group.lambda_sg[0].id : null)
}

output role_name {
  value = aws_iam_role.lambda_role.name
}

output git_repo {
  value = var.git_repo
}

# Optional dead letter queue information

output dead_letter_queue_arn {
  value = (
    var.create_dead_letter_queue ?
    aws_sqs_queue.dead_letter_queue[0].arn :
    null
  )
}

output dead_letter_queue_name {
  value = (
    var.create_dead_letter_queue ?
    aws_sqs_queue.dead_letter_queue[0].name :
    null
  )
}

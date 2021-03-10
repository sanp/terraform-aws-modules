output name {
  value = aws_sqs_queue.queue.name
}

output arn {
  value = aws_sqs_queue.queue.arn
}

output dlq_name {
  value = aws_sqs_queue.dead_letter_queue.name
}

output dlq_arn {
  value = aws_sqs_queue.dead_letter_queue.arn
}

output arn {
  value = aws_emr_cluster.emr.arn
}

output id {
  value = aws_emr_cluster.emr.id
}

output name {
  value = var.name
}

output master_public_dns {
  value = aws_emr_cluster.emr.master_public_dns
}

output log_uri {
  value = aws_emr_cluster.emr.log_uri
}

output ec2_attributes {
  value = aws_emr_cluster.emr.ec2_attributes
}

/*
 Roles
*/

# Service role

output service_role_arn {
  value = aws_iam_role.emr.arn
}

output service_role_name {
  value = aws_iam_role.emr.name
}

# Instance profile

output instance_profile_arn {
  value = aws_iam_instance_profile.ec2.arn
}

output instance_profile_name {
  value = aws_iam_instance_profile.ec2.name
}

# Instance profile role

output instance_profile_role_arn {
  value = aws_iam_role.ec2.arn
}

output instance_profile_role_name {
  value = aws_iam_role.ec2.name
}

# Autoscaling role

output autoscaling_role_arn {
  value = aws_iam_role.ec2_autoscaling.arn
}

output autoscaling_role_name {
  value = aws_iam_role.ec2_autoscaling.name
}

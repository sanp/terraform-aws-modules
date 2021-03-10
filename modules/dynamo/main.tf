# Create Dynamo table
resource "aws_dynamodb_table" "table" {

  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.write_capacity
  write_capacity = var.read_capacity
  hash_key       = var.table_key

  attribute {
    name = var.table_key
    type = var.table_key_type
  }

  tags = merge(
    var.base_tags,
    {
      "Name" = var.table_name,
    }
  )

}

# Add items to Dynamo table
resource "aws_dynamodb_table_item" "table" {
  for_each = var.table_items

  table_name = aws_dynamodb_table.table.name
  hash_key   = aws_dynamodb_table.table.hash_key

  item = <<ITEM
{
  "${var.table_key}": {"${var.table_key_type}": "${each.value}"}
}
ITEM
}

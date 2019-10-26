output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
}

output "all_subnet_ids" {
  value = concat(
    sort(aws_subnet.private_subnet.*.id),
    sort(aws_subnet.public_subnet.*.id),
  )
}
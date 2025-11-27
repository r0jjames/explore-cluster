resource "local_file" "pet" {
  content  = "foo"
  filename = each.value
  for_each = toset(var.filename)
}

output "pets" {
  value     = local_file.pet
  sensitive = true
}

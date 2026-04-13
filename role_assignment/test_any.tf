variable "assignments" {
  type = map(object({
    principal = any
  }))
}

locals {
  p       = var.assignments["test"].principal
  is_list = can(tolist(local.p))
}

output "out" {
  value = local.is_list
}

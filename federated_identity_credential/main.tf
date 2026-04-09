resource "azurerm_federated_identity_credential" "this" {
  for_each = { for c in var.credentials : c.name => c }

  name                      = each.value.name
  user_assigned_identity_id = each.value.user_assigned_identity_id
  issuer                    = each.value.issuer
  subject                   = each.value.subject
  audience                  = each.value.audience
  description               = lookup(each.value, "description", null)
}

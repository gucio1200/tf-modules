resource "azurerm_federated_identity_credential" "this" {
  for_each = { for c in var.credentials : c.name => c }

  name                      = each.value.name
  user_assigned_identity_id = coalesce(each.value.user_assigned_identity_id, var.default_user_assigned_identity_id)
  issuer                    = coalesce(each.value.issuer, var.default_issuer)
  subject                   = "system:serviceaccount:${each.value.namespace}:${each.value.name}"
  audience                  = coalesce(each.value.audience, var.default_audience)
  description               = lookup(each.value, "description", null)
}

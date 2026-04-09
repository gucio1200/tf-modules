locals {
  # Add all your new workload definitions here.
  # You do not need to modify main.tf when adding new workloads.

  predefined_configs = {
    "app-workload-1" = {
      federated_identity_credentials = [
        { name = "app-workload-1-fic-1", namespace = "default" },
        { name = "app-workload-1-fic-2", namespace = "kube-system" }
      ]
      role_assignments = [
        { role_definition_name = "Reader" },
        { role_definition_name = "AcrPull" }
      ]
    }

    "app-workload-custom-roles" = {
      role_assignments = [
        { role_definition_name = "Contributor" }
      ]
    }

    "app-workload-only-fic" = {
      federated_identity_credentials = [
        { name = "app-workload-fic-only", namespace = "monitoring" }
      ]
    }
  }
}

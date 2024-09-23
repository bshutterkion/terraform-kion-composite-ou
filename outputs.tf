output "ou_id" {
  description = "The ID of the OU created by this module."
  value       = module.ou.ou_id
}

output "user_group_ids" {
  description = "Map of user group IDs created by this module."
  value = {
    for name, group in module.user_groups : name => try(group.user_group_id, null)
  }
}

output "compliance_standard_ids" {
  description = "The IDs of the created compliance standards, if any"
  value       = length(module.compliance_standards) > 0 ? [for cs in values(module.compliance_standards) : cs.compliance_standard_id] : null
}

output "cloud_rule_ids" {
  description = "Map of cloud rule IDs created by this module."
  value       = { for name, cr in module.cloud_rules : name => cr.cloud_rule_id }
}

output "ou_car_ids" {
  description = "Map of OU cloud access role IDs created by this module."
  value = {
    for name, car in module.ou_cars : name => car.ou_car_id
  }
}

output "iam_policy_ids" {
  description = "IDs of the created IAM policies."
  value       = { for k, v in module.iam_policies : k => v.policy_ids[0] }
}

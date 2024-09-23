module "ou" {
  source = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/ou"

  name                 = var.ou_name
  description          = var.ou_name
  parent_ou_id         = var.parent_ou_id
  owner_users          = var.owner_users
  owner_user_groups    = var.owner_user_groups
  permission_scheme_id = var.permission_scheme_id
  labels               = { for k, v in var.labels : k => v.value }
}

module "user_groups" {
  source       = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/user-group"
  for_each     = { for group in var.user_groups : group.group_name => group }
  name         = "${var.ou_name} ${each.value.group_name}"
  description  = "${var.ou_name} ${each.value.group_name} User Group"
  idms_id      = each.value.idms_id
  owner_users  = [for id in var.owner_users : { id = id }]
  owner_groups = [for id in var.owner_user_groups : { id = id }]
  users        = []
  depends_on   = [module.ou]
}


module "compliance_checks" {
  source   = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/compliance-check"
  for_each = { for check in local.compliance_checks : check.key => check }
  name = each.value.is_system_check ? "${each.value.template}" : coalesce(
    compact([
      for ext in local.remove_extensions : (
        endswith(basename(each.value.template), ext)
        ? substr(basename(each.value.template), 0, length(basename(each.value.template)) - length(ext))
        : null
      )
    ])[0],
    basename(each.value.template)
  )
  cloud_provider_id        = try(local.cloud_provider_id_map[each.value.overrides.csp], 1)
  compliance_check_type_id = try(local.compliance_check_type_map[each.value.overrides.compliance_check_type], 2)
  body_template            = each.value.is_system_check ? null : each.value.template
  owner_users              = [for id in var.owner_users : { id = id }]
  owner_user_groups        = [for id in var.owner_user_groups : { id = id }]
  is_system_check          = each.value.is_system_check
  created_by_user_id       = var.owner_users[0]
  compliance_standard_name = each.value.compliance_standard_name
  frequency_minutes        = try(each.value.overrides.frequency, null)
  frequency_type_id        = try(local.frequency_type_map[each.value.overrides.frequency_type], null)
  is_all_regions           = try(each.value.overrides.all_regions, false)
  is_auto_archived         = try(each.value.overrides.auto_archive, false)
  regions                  = try(each.value.overrides.regions, ["us-east-1"])
  severity_type_id         = try(each.value.overrides.severity_type_id, null)
}

module "compliance_standards" {
  source   = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/compliance-standard"
  for_each = local.compliance_standards

  name               = each.value.name
  description        = each.value.description
  created_by_user_id = var.owner_users[0]
  owner_users        = [for id in var.owner_users : { id = id }]
  owner_user_groups  = [for id in var.owner_user_groups : { id = id }]
  compliance_checks = [
    for check in each.value.checks :
    { id = module.compliance_checks[check.key].compliance_check_id }
  ]
}

module "iam_policies" {
  source   = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/aws-iam-policy"
  for_each = { for policy in local.all_policies : policy.key => policy if policy.type == "user_managed" }

  name = coalesce(
    compact([
      for ext in var.remove_extensions : (
        endswith(each.value.name, ext)
        ? substr(each.value.name, 0, length(each.value.name) - length(ext))
        : null
      )
    ])[0],
    each.value.name
  )

  policy_template         = each.value.policy_template
  owner_users             = [for id in var.owner_users : { id = id }]
  owner_user_groups       = [for id in var.owner_user_groups : { id = id }]
  policy_type             = each.value.type
  system_managed_policies = var.system_managed_policies
}

module "scps" {
  source   = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/aws-service-control-policy"
  for_each = local.scp_map
  name = "SCP-${coalesce(
    compact([
      for ext in local.remove_extensions : (
        endswith(basename(each.value), ext)
        ? substr(basename(each.value), 0, length(basename(each.value)) - length(ext))
        : null
      )
    ])[0],
    basename(each.value)
  )}"
  scp_policy_template = each.value
  description         = "SCP for ${var.ou_name}: ${basename(each.value)}"
  owner_users         = [for id in var.owner_users : { id = id }]
  owner_user_groups   = var.owner_user_groups
  ou_name             = var.ou_name
}

module "cloudformation_templates" {
  source   = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/aws-cloudformation-template"
  for_each = local.cloudformation_template_map

  name                   = each.value.name
  regions                = try(each.value.regions, ["*"]) // Default to all regions if not specified
  owner_users            = [for id in var.owner_users : { id = id }]
  owner_user_groups      = [for id in var.owner_user_groups : { id = id }]
  description            = each.value.description
  policy                 = each.value.policy
  policy_template        = each.value.policy_template
  region                 = try(each.value.region, null)
  sns_arns               = try(each.value.sns_arns, null)
  template_parameters    = try(each.value.template_parameters, null)
  termination_protection = try(each.value.termination_protection, false)
  tags                   = try(each.value.tags, {})
}

module "cloud_rules" {
  source = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/cloud-rule"

  for_each          = { for cr in var.cloud_rules : cr.name => cr }
  name              = each.value.name
  description       = each.value.description
  owner_users       = [for id in var.owner_users : { id = id }]
  owner_user_groups = [for id in var.owner_user_groups : { id = id }]
  ous               = [{ id = module.ou.ou_id }]

  service_control_policies = [
    for scp in try(each.value.cloud_rule_attachments.scps, []) : { id = module.scps[each.key].scp_id }
  ]

  aws_iam_policies = flatten([
    # Process user-managed policies
    [
      for policy in try(each.value.cloud_rule_attachments.aws_iam_policies.user_managed, []) : {
        id = module.iam_policies[replace(basename(policy.template), "\\.(tpl|json|ya?ml)$", "")].policy_id
      }
    ],
    # Process system-managed policies
    [
      for policy in try(each.value.cloud_rule_attachments.aws_iam_policies.system_managed, []) : {
        id = local.policy_id_map[policy]
      }
    ]
  ])

  compliance_standards = [
    for cs in coalesce(try(each.value.cloud_rule_attachments.compliance_standards, []), []) : {
      id = module.compliance_standards[cs].compliance_standard_id
    }
  ]

  aws_cloudformation_templates = [
    for cft in try(each.value.cloud_rule_attachments.cloudformation_templates, []) : {
      id = try(local.cloudformation_template_id_map[cft], null)
    }
    if can(local.cloudformation_template_id_map[cft])
  ]

  depends_on = [module.compliance_standards, module.ou, module.scps, module.iam_policies, module.cloudformation_templates]
}


module "ou_cars" {
  source   = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/ou-cloud-access-role"
  for_each = { for car in var.cloud_access_roles : car.name => car }

  name                   = each.value.name
  ou_id                  = module.ou.ou_id
  aws_iam_role_name      = each.value.aws_iam_role_name
  web_access             = try(each.value.web_access, true)
  short_term_access_keys = try(each.value.short_term_access_keys, true)
  long_term_access_keys  = try(each.value.long_term_access_keys, false)

  aws_iam_policies = [
    for policy in local.car_policies :
    { id = local.policy_id_map[policy.key] }
    if policy.car_name == each.value.name
  ]

  user_groups = distinct(concat(
    [for group_name in each.value.user_groups : { id = try(local.user_group_name_to_id[group_name], null) }],
    [for id in var.owner_user_groups : { id = id }]
  ))

  users      = [for user_id in each.value.users : { id = user_id }]
  depends_on = [module.ou, module.iam_policies, module.user_groups]
}

module "ou_permission_mapping" {
  source = "/Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/ou-permission-mapping"
  ou_id  = module.ou.ou_id


  permission_mappings = [
    for app_role_id, group_ids in local.user_groups_by_role : {
      app_role_id    = app_role_id
      user_group_ids = toset(group_ids)
      user_ids       = []
    }
  ]

  depends_on = [module.ou, module.user_groups]
}

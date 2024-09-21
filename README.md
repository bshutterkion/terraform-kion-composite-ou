<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kion"></a> [kion](#requirement\_kion) | ~> 0.3.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kion"></a> [kion](#provider\_kion) | ~> 0.3.18 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_rules"></a> [cloud\_rules](#module\_cloud\_rules) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/cloud-rule | n/a |
| <a name="module_compliance_checks"></a> [compliance\_checks](#module\_compliance\_checks) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/compliance-check | n/a |
| <a name="module_compliance_standards"></a> [compliance\_standards](#module\_compliance\_standards) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/compliance-standard | n/a |
| <a name="module_iam_policies"></a> [iam\_policies](#module\_iam\_policies) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/aws-iam-policy | n/a |
| <a name="module_ou"></a> [ou](#module\_ou) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/ou | n/a |
| <a name="module_ou_cars"></a> [ou\_cars](#module\_ou\_cars) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/ou-cloud-access-role | n/a |
| <a name="module_ou_permission_mapping"></a> [ou\_permission\_mapping](#module\_ou\_permission\_mapping) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/ou-permission-mapping | n/a |
| <a name="module_scps"></a> [scps](#module\_scps) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/aws-service-control-policy | n/a |
| <a name="module_user_groups"></a> [user\_groups](#module\_user\_groups) | /Users/bshutter/Dev/code/kion/bshutter/github/bshutterkion/kion-modules/user-group | n/a |

## Resources

| Name | Type |
|------|------|
| [kion_aws_iam_policy.system_managed](https://registry.terraform.io/providers/kionsoftware/kion/latest/docs/data-sources/aws_iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_role_id"></a> [app\_role\_id](#input\_app\_role\_id) | The application role ID to assign the created user groups. | `number` | `null` | no |
| <a name="input_cloud_access_roles"></a> [cloud\_access\_roles](#input\_cloud\_access\_roles) | List of cloud access roles to create. | <pre>list(object({<br>    name              = string<br>    aws_iam_role_name = string<br>    aws_iam_policies = object({<br>      user_managed   = optional(list(object({ template = string })), [])<br>      system_managed = optional(list(string), [])<br>    })<br>    web_access             = optional(bool, true)<br>    short_term_access_keys = optional(bool, true)<br>    long_term_access_keys  = optional(bool, false)<br>    user_groups            = optional(list(string), [])<br>    users                  = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_cloud_provider_id"></a> [cloud\_provider\_id](#input\_cloud\_provider\_id) | The ID of the cloud provider. | `number` | `1` | no |
| <a name="input_cloud_rule_attachments"></a> [cloud\_rule\_attachments](#input\_cloud\_rule\_attachments) | Attachments for the cloud rule. | <pre>object({<br>    aws_iam_policies = optional(object({<br>      user_managed   = optional(list(string))<br>      system_managed = optional(list(string))<br>    }))<br>    compliance_standard = object({<br>      compliance_checks = object({<br>        user_managed = list(object({<br>          template = string<br>          overrides = optional(object({<br>            regions               = optional(list(string))<br>            auto_archive          = optional(bool)<br>            all_regions           = optional(bool)<br>            severity              = optional(string)<br>            frequency             = optional(number)<br>            frequency_type        = optional(string)<br>            compliance_check_type = optional(string)<br>            csp                   = optional(string)<br>          }))<br>        }))<br>        system_managed = list(object({<br>          template = string<br>          overrides = optional(object({<br>            severity       = optional(string)<br>            frequency      = optional(number)<br>            frequency_type = optional(string)<br>          }))<br>        }))<br>      })<br>    })<br>  })</pre> | `null` | no |
| <a name="input_cloud_rules"></a> [cloud\_rules](#input\_cloud\_rules) | List of cloud rules. | <pre>list(object({<br>    name        = string<br>    description = optional(string)<br>    cloud_rule_attachments = optional(object({<br>      scps = optional(list(string))<br>      aws_iam_policies = optional(object({<br>        user_managed   = optional(list(object({ template = string })), [])<br>        system_managed = optional(list(string), [])<br>      }))<br>    }))<br>    compliance_standards = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_compliance_check_type_id"></a> [compliance\_check\_type\_id](#input\_compliance\_check\_type\_id) | The ID of the compliance check type. | `number` | `2` | no |
| <a name="input_compliance_standards"></a> [compliance\_standards](#input\_compliance\_standards) | List of compliance standards. | <pre>list(object({<br>    name        = string<br>    description = optional(string)<br>    compliance_checks = optional(object({<br>      user_managed = optional(list(object({<br>        template = string<br>        overrides = optional(object({<br>          regions               = optional(list(string))<br>          auto_archive          = optional(bool)<br>          all_regions           = optional(bool)<br>          severity              = optional(string)<br>          frequency             = optional(number)<br>          frequency_type        = optional(string)<br>          compliance_check_type = optional(string)<br>          csp                   = optional(string)<br>        }))<br>      })), [])<br>      system_managed = optional(list(object({<br>        template = string<br>        overrides = optional(object({<br>          severity       = optional(string)<br>          frequency      = optional(number)<br>          frequency_type = optional(string)<br>        }))<br>      })), [])<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the OU. | `string` | `null` | no |
| <a name="input_frequency_minutes"></a> [frequency\_minutes](#input\_frequency\_minutes) | Frequency of the compliance check in minutes. | `number` | `60` | no |
| <a name="input_frequency_type_id"></a> [frequency\_type\_id](#input\_frequency\_type\_id) | The frequency type ID. | `number` | `2` | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | List of IAM policies to create and attach. | <pre>list(object({<br>    name                 = string<br>    policy_template      = optional(string)<br>    attach_to_cloud_rule = optional(bool, false)<br>    attach_to_car        = optional(string)<br>    type                 = string<br>  }))</pre> | `[]` | no |
| <a name="input_idms_id"></a> [idms\_id](#input\_idms\_id) | IDMS ID for the user groups. | `number` | `null` | no |
| <a name="input_is_all_regions"></a> [is\_all\_regions](#input\_is\_all\_regions) | Whether the compliance check applies to all regions. | `bool` | `true` | no |
| <a name="input_is_auto_archived"></a> [is\_auto\_archived](#input\_is\_auto\_archived) | Whether the compliance check is auto-archived. | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to assign to the OU. | <pre>map(object({<br>    value = string<br>    color = string<br>  }))</pre> | `{}` | no |
| <a name="input_ou_name"></a> [ou\_name](#input\_ou\_name) | Alias of the OU, used as a prefix for resource names. | `string` | n/a | yes |
| <a name="input_owner_user_groups"></a> [owner\_user\_groups](#input\_owner\_user\_groups) | List of owner user group IDs for the OU. | `list(number)` | n/a | yes |
| <a name="input_owner_users"></a> [owner\_users](#input\_owner\_users) | List of owner user IDs for the OU. | `list(number)` | n/a | yes |
| <a name="input_parent_ou_id"></a> [parent\_ou\_id](#input\_parent\_ou\_id) | Organizational Unit ID where the OU will be a descendant. | `number` | n/a | yes |
| <a name="input_permission_scheme_id"></a> [permission\_scheme\_id](#input\_permission\_scheme\_id) | Permission scheme ID for the ou. | `number` | `2` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Regions where the compliance check applies. | `list(string)` | <pre>[<br>  "us-east-1"<br>]</pre> | no |
| <a name="input_scp_policy"></a> [scp\_policy](#input\_scp\_policy) | The JSON policy document for the Service Control Policy (SCP). | `string` | `null` | no |
| <a name="input_scp_policy_template"></a> [scp\_policy\_template](#input\_scp\_policy\_template) | List of paths to template files for the Service Control Policies (SCPs). | `list(string)` | `[]` | no |
| <a name="input_severity_type_id"></a> [severity\_type\_id](#input\_severity\_type\_id) | The severity type ID. | `number` | `3` | no |
| <a name="input_user_groups"></a> [user\_groups](#input\_user\_groups) | List of user groups to create, with IDMS ID, group name, and app role ID. | <pre>list(object({<br>    idms_id     = number<br>    group_name  = string<br>    app_role_id = number<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_rule_ids"></a> [cloud\_rule\_ids](#output\_cloud\_rule\_ids) | Map of cloud rule IDs created by this module. |
| <a name="output_compliance_standard_ids"></a> [compliance\_standard\_ids](#output\_compliance\_standard\_ids) | The IDs of the created compliance standards, if any |
| <a name="output_iam_policy_ids"></a> [iam\_policy\_ids](#output\_iam\_policy\_ids) | IDs of the created IAM policies. |
| <a name="output_ou_car_ids"></a> [ou\_car\_ids](#output\_ou\_car\_ids) | Map of OU cloud access role IDs created by this module. |
| <a name="output_ou_id"></a> [ou\_id](#output\_ou\_id) | The ID of the OU created by this module. |
| <a name="output_user_group_ids"></a> [user\_group\_ids](#output\_user\_group\_ids) | Map of user group IDs created by this module. |
<!-- END_TF_DOCS -->